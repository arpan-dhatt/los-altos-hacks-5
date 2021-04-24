// This crate provides two functions that encode and decode `i32` to and from `8` hexadecimal `u8`
// bytes. This is for the hcitool which requires inputting hexadecimal advertisement package data
// from the command line. This converts an arbitrary `i32` into the required bytes that can be used
// later.
//
// This can be used with floats but they must be discretized by dividing by some preset
// interval as shown in the tests in `src/lib.rs`. Look at the required decimal precision required
// for the application. `5` decimals of precision should be enough for GPS long/lat applications
// where a granularity of a few cm is required.

pub fn encode_discrete(mut discrete: i32) -> [u8; 8] {
    // Converts an `i32` to a sequence of 8 ASCII bytes corresponding to hexadecimal values that
    // can be used in hcitool cmd to send a specific set of bytes. Each `u8` byte can have `16`
    // (only `4` bits of information) and therefore the `8` byte output only contains the information
    // for `32` bits.

    let mut enc = [b'0'; 8];
    for i in 0..8 {
        // get only the 4 least significant bits
        let four_bits = discrete & 0b1111;
        // convert them to one hex value and assign them a spot in the output
        enc[i] = to_hex(four_bits);
        // shift right to remove the values for next loop iteration
        discrete >>= 4;
    }
    enc
}

pub fn decode_discrete(enc: [u8; 8]) -> i32 {
    // Converts a set of `8` ASCII bytes that represent hexadecimal into a two's-complement `i32`.
    // These bytes must be valid hexadecimal and therefore can only have ASCII values 0-9 and A-F.

    let mut discrete = 0;
    for i in 0..8 {
        // shift left to make room for next bits
        discrete <<= 4;
        // "add" these bits to the output. A bitwise or is fine since left shift by 4 guarantees 4
        // 0's.
        discrete |= from_hex(enc[7 - i]);
    }
    discrete
}

fn to_hex(num: i32) -> u8 {
    assert!(num >= 0 && num < 16);
    match num {
        0 => b'0',
        1 => b'1',
        2 => b'2',
        3 => b'3',
        4 => b'4',
        5 => b'5',
        6 => b'6',
        7 => b'7',
        8 => b'8',
        9 => b'9',
        10 => b'A',
        11 => b'B',
        12 => b'C',
        13 => b'D',
        14 => b'E',
        15 => b'F',
        _ => b'0',
    }
}

fn from_hex(byte: u8) -> i32 {
    match byte {
        b'0' => 0,
        b'1' => 1,
        b'2' => 2,
        b'3' => 3,
        b'4' => 4,
        b'5' => 5,
        b'6' => 6,
        b'7' => 7,
        b'8' => 8,
        b'9' => 9,
        b'A' => 10,
        b'B' => 11,
        b'C' => 12,
        b'D' => 13,
        b'E' => 14,
        b'F' => 15,
        _ => 0,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn transcode_float_test() {
        let val = (0.0 / 0.00001) as i32;
        assert_eq!(val, decode_discrete(encode_discrete(val)));
        let val = (-180.0233 / 0.00001) as i32;
        assert_eq!(val, decode_discrete(encode_discrete(val)));
        let val = (180.2323 / 0.00001) as i32;
        assert_eq!(val, decode_discrete(encode_discrete(val)));
        let val = (-0.2343 / 0.00001) as i32;
        assert_eq!(val, decode_discrete(encode_discrete(val)));
        let val = (0.2355 / 0.00001) as i32;
        assert_eq!(val, decode_discrete(encode_discrete(val)));
    }
}
