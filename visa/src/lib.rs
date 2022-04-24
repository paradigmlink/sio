extern crate pest;
#[macro_use]
extern crate pest_derive;
pub use {
    pest::Parser,
};

#[derive(Parser)]
#[grammar = "grammar/sio_visa.pest"]
pub struct SioVisaParser;

#[cfg(test)]
mod parse_tests {
    use super::*;

    #[test]
    fn mod_test() {
        use std::fs;
        let unparsed_file = fs::read_to_string("examples/mod_test.siov").expect("cannot read file");
        let parsed = SioVisaParser::parse(Rule::main, &unparsed_file);
        match parsed {
            Ok(mut res) => {
                for module in res.next().unwrap().into_inner() {
                    match module.as_rule() {
                        Rule::module => {
                            println!("{:#?}", module);
                        }
                        _ => (),
                    }
                }
            },
            Err(e) => {
                println!("{:#?}", e);
                panic!()
            }
        }
    }
}
