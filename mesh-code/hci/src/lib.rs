use std::io::{BufRead, BufReader};
use std::process::{Child, Command, Output, Stdio};

fn get_raw_advertising_data(bytes: &[u8; 40]) -> String {
    // This data header is used to define this packet as an Eddystone advertisement. There are
    // still `20` bytes remaining that can be used.

    let mut data = "0x08 0x0008 1f 02 01 06 03 03 aa fe 14 16 aa fe ".to_string();
    // Loops over the 20 available bytes
    for i in 0..20 {
        let byte_str = String::from_utf8_lossy(&bytes[i..i + 2]);
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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn get_raw_advertising_data_test() {
        assert_eq!(
            "0x08 0x0008 1f 02 01 06 03 03 aa fe 14 16 aa fe 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00",
            get_raw_advertising_data(&[b'0'; 40])
        );
        assert_eq!(
            "0x08 0x0008 1f 02 01 06 03 03 aa fe 14 16 aa fe 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11",
            get_raw_advertising_data(&[b'1'; 40])
        );
    }

    #[test]
    fn run_hci_commands() {

    }
}
