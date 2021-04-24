use hci;
use data_transcoder;

fn main() {
    let lescan_thread = std::thread::spawn(hci::activate_lescan);
    let scanner = hci::packet_reader();
    for item in scanner {
        println!("{}", item)
    }
    println!("{:?}", lescan_thread.join());
}
