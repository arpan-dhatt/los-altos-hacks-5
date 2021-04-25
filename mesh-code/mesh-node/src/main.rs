use std::sync::mpsc::{Sender, channel};
use hci;
use data_transcoder;

fn main() {
    let lescan_thread = std::thread::spawn(hci::activate_lescan);
    let (packet_tx, packet_rx) = channel::<[u8; 40]>();
    let packet_thread = std::thread::spawn(|| packet_thread_fn(packet_tx));
    println!("{:?} {:?}", lescan_thread.join(), packet_thread.join());
}

fn packet_thread_fn(tx: Sender<[u8; 40]>) {
    let scanner = hci::packet_reader();
    for packet in scanner {
        if is_eddystone_packet(&packet) {
            if let Some(data) = extract_data(&packet) {
                println!("{}", String::from_utf8_lossy(&data));
            }
        }
    }
}

fn is_eddystone_packet(packet: &str) -> bool {
    packet.contains("1F0201060303AAFE1716AAFE")
}

fn extract_data(packet: &str) -> Option<[u8; 40]> {
    let eddystone_header = "1F0201060303AAFE1716AAFE";
    if let Some(header_start) = packet.find(eddystone_header) {
        let data_start = header_start + eddystone_header.len();
        let mut out = [b'0'; 40];
        for i in 0..40 {
            if let Some(c) = packet.as_bytes().get(i) {
                out[i] = *c;
            }
            else {
                return None
            }
        }
        return Some(out);
    }
    None
}
