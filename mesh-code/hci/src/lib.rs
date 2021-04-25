use std::io::{BufRead, BufReader};
use std::process::{Child, Command, Output, Stdio};

pub fn get_raw_advertising_data(bytes: &[u8; 40]) -> String {
    // This data header is used to define this packet as an Eddystone advertisement. There are
    // still `20` bytes remaining that can be used.

    let mut data = "0x08 0x0008 1F 02 01 06 03 03 AA FE 14 16 AA FE ".to_string();
    // Loops over the 20 available bytes
    for i in 0..20 {
        let byte_str = String::from_utf8_lossy(&bytes[i * 2..(i + 1) * 2]);
        data += &byte_str;
        data.push(' ');
    }
    // Removes the trailing space
    data.pop();

    data
}

pub fn activate_lescan() -> std::io::Result<Output> {
    // Starts the `hcitool lescan` process which will allow advertising packets to be received by
    // the other `hcidump` process where they can be decoded to useful information. This function
    // will only work on a Linux machine with Bluetooth and `hcitool` properly installed. This
    // function will block forever so it should be run on a separate thread just for running this
    // process.

    Command::new("hcitool")
        .arg("lescan")
        .arg("--duplicates") // Allows data from the same device to come again
        .arg("--passive") // Doesn't request for scan response data
        .stdout(Stdio::null()) // We don't need the output, so trash it
        .output()
}

fn start_packet_dump_process() -> Child {
    // Starts the `hcidump` process which receives raw bluetooth advertising packets which can be
    // properly decoded. This function will only work on a Linux machine with Bluetooth and
    // `hcidump` properly installed.

    Command::new("hcidump")
        .arg("--raw") // Gets raw data
        .stdout(Stdio::piped()) // We need this output, so pipe it
        .spawn()
        .expect("failed to start dump process")
}

pub fn packet_reader() -> impl Iterator<Item = String> {
    // Gets started `hcidump` process and returns an iterator that contains a packet received by
    // the `hcudump` process. They have been converted into strings and unnecessary data has been
    // removed. These can be scanned for identifiers and processed. They are ASCII-encoded byte
    // strings.

    let dump_child_process = start_packet_dump_process();
    // Does partial move of child process
    let stdout = dump_child_process.stdout.expect("failed to get stdout");

    // `BufReader` takes ownership of `stdout` so it can be returned as an iterator and RAII is
    // enforced when this reader is dropped and the `ChildStdout` and `Child` structs are are
    // freed.
    BufReader::new(stdout)
        .split(b'>') // Splits by packet
        .filter_map(|e| match e {
            Ok(e) => Some(e),
            _ => None,
        }) // Removes any failed lines
        .map(|e| {
            String::from_utf8_lossy(&e)
                .split_whitespace()
                .collect::<String>()
        }) // Removes unnecessary whitespace from output
}

pub fn set_advertising_data(bytes: &[u8; 40]) -> std::io::Result<Output> {
    // Sets the advertising data of the first Host-Controller interface on the device to begin
    // broadcasting the data that is supplied above at a rate of 10 Hz. This function will only
    // work on a Linux machine with Bluetooth and `hcitool` properly installed.

    // Sets the advertising data
    Command::new("hcitool")
        .arg("cmd")
        .args(get_raw_advertising_data(bytes).split(' '))
        .output()?;

    // Sets the advertising interval to 10Hz
    Command::new("hcitool")
        .arg("cmd")
        .args("0x08 0x0006 A0 00 A0 00 03 00 00 00 00 00 00 00 00 07 00".split(' '))
        .output()?;

    // Sets the advertising mode to advertising and non-connectable: A beacon
    Command::new("hcitool")
        .arg("cmd")
        .args("0x08 0x000a 01".split(' '))
        .output()
}

pub fn stop_advertising() -> std::io::Result<Output> {
    // Ends advertising on the device using the Host-Controller Insterface on the device.

    Command::new("hciconfig")
        .arg("hci0")
        .arg("noleadv")
        .output()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn get_raw_advertising_data_test() {
        assert_eq!(
            "0x08 0x0008 1F 02 01 06 03 03 AA FE 14 16 AA FE 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00",
            get_raw_advertising_data(&[b'0'; 40])
        );
        assert_eq!(
            "0x08 0x0008 1F 02 01 06 03 03 AA FE 14 16 AA FE 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11",
            get_raw_advertising_data(&[b'1'; 40])
        );
    }

    #[test]
    fn set_advertising_data_test() {
        use data_transcoder::*;

        let latitude = (34.0023 / 0.00001) as i32;
        let longitude = (-74.3321 / 0.00001) as i32;
        let latitude_data = encode_discrete(latitude);
        let longitude_data = encode_discrete(longitude);
        let mut full_data = [b'0'; 40];
        for i in 0..8 {
            full_data[i] = latitude_data[i];
            full_data[i + 8] = longitude_data[i];
        }
        let adv_data = get_raw_advertising_data(&full_data);
        let mimiced_string = mimic_received_data(adv_data);
        let test_received_data = mimiced_string.as_bytes();
        let mut encoded_latitude = [b'0'; 8];
        let mut encoded_longitude = [b'0'; 8];
        for i in 0..8 {
            encoded_latitude[i] = test_received_data[i];
            encoded_longitude[i] = test_received_data[i + 8];
        }
        let decoded_latitude = decode_discrete(&encoded_latitude);
        let decoded_longitude = decode_discrete(&encoded_longitude);
        assert_eq!(latitude, decoded_latitude);
        assert_eq!(longitude, decoded_longitude);
    }

    fn mimic_received_data(generated: String) -> String {
        (&generated.replace(" ", "")[34..]).to_string()
    }
}
