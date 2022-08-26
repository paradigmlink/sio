use std::env;
extern crate pest;
#[macro_use]
extern crate pest_derive;

#[cfg(test)]
mod tests;

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();

    if args.len() != 1 {
        eprintln!("Usage: sio [path]");
        return;
    }

    let path = args.first().unwrap();
    let data = std::fs::read_to_string(path).unwrap();
    let module = sio_compiler::compile();
}
