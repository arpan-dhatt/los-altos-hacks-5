use data_transcoder::*;
use hci;
use std::{collections::HashMap, io::Read, net::{TcpListener, TcpStream}, sync::mpsc::{Receiver, Sender, channel}, time};

fn main() {
    let lescan_thread = std::thread::spawn(hci::activate_lescan);

    let (packet_tx, packet_rx) = channel::<[u8; 40]>();

    let packet_thread_tx = packet_tx.clone();
    let packet_thread = std::thread::spawn(|| packet_thread_fn(packet_thread_tx));

    let graph_ingress_tx = packet_tx.clone();
    let graph_ingress_thread = std::thread::spawn(|| graph_ingress_fn(graph_ingress_tx));

    let advertiser_thread = std::thread::spawn(|| periodic_advertisement_controller(packet_rx));
    println!("{:?} {:?} {:?}, {:?}", lescan_thread.join(), packet_thread.join(), graph_ingress_thread.join(), advertiser_thread.join());
}

fn packet_thread_fn(tx: Sender<[u8; 40]>) {
    let scanner = hci::packet_reader();
    for packet in scanner {
        if is_eddystone_packet(&packet) {
            if let Some(data) = extract_data(&packet) {
                tx.send(data).unwrap();
            }
        }
    }
}

fn is_eddystone_packet(packet: &str) -> bool {
    packet.contains("1F0201060303AAFE1416AAFE")
}

fn extract_data(packet: &str) -> Option<[u8; 40]> {
    let eddystone_header = "1F0201060303AAFE1416AAFE";
    if let Some(header_start) = packet.find(eddystone_header) {
        let data_start = header_start + eddystone_header.len();
        let mut out = [b'0'; 40];
        for i in 0..40 {
            if let Some(c) = packet.as_bytes().get(data_start + i) {
                out[i] = *c;
            } else {
                return None;
            }
        }
        return Some(out);
    }
    None
}

fn basic_advertisement_controller(rx: Receiver<[u8; 40]>) {
    let mut current_adv_data = None;

    for new_data in rx {
        println!("{}", String::from_utf8_lossy(&new_data));
        if let Some(old_data) = current_adv_data {
            if &old_data != &new_data {
                current_adv_data = Some(new_data);
                hci::set_advertising_data(&current_adv_data.unwrap()).unwrap();
            }
        } else {
            current_adv_data = Some(new_data);
            hci::set_advertising_data(&current_adv_data.unwrap()).unwrap();
        }
    }
}

fn periodic_advertisement_controller(rx: Receiver<[u8; 40]>) {
    let mut first_seen: HashMap<[u8; 40], time::Instant> = HashMap::new(); // WARNING: UNBOUNDED SIZE HASHMAP

    for new_data in rx {
        println!("{}", String::from_utf8_lossy(&new_data));
        if first_seen.contains_key(&new_data) { // this is a repeat message
            if first_seen.get(&new_data).unwrap().elapsed().as_millis() > 60000 { // it's been long enough so let's resend this
                first_seen.insert(new_data.clone(), time::Instant::now());
                hci::set_advertising_data(&new_data).unwrap();
            }
        } else { // completely new message so it should be set immediately
            first_seen.insert(new_data.clone(), time::Instant::now());
            hci::set_advertising_data(&new_data).unwrap();
        }
    }
}

fn graph_ingress_fn(tx: Sender<[u8; 40]>) {
    let listener = TcpListener::bind("127.0.0.1:7878").unwrap();

    for connection in listener.incoming() {
        if let Ok(stream) = connection {
            if let Some((lat, long)) = handle_connection(stream) {
                let mut advert_data = [b'0'; 40];
                let lat_encoded = encode_discrete((lat / 0.00001) as i32);
                let long_encoded = encode_discrete((long / 0.00001) as i32);
                for i in 0..8 {
                    advert_data[i] = lat_encoded[i];
                    advert_data[i+8] = long_encoded[i];
                }
                tx.send(advert_data).unwrap();
            }
        }
    }

}

fn handle_connection(mut stream: TcpStream) -> Option<(f32, f32)> {
    let mut buffer = [0u8; 1024];
    if stream.read(&mut buffer).is_ok() {
        let stringified = String::from_utf8_lossy(&buffer);
        let mut numbers = stringified
            .split_whitespace()
            .map(|e| e.parse::<f32>())
            .filter_map(|e| match e {
                Ok(n) => Some(n),
                _ => None,
            });
        if let (Some(latitude), Some(longitude)) = (numbers.next(), numbers.next()) {
            return Some((latitude, longitude))
        }
    }
    None
}
