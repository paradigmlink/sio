extern crate pest;
#[macro_use]
extern crate pest_derive;
pub use {
    pest::Parser,
    serde::{de, Deserialize, Deserializer},
    std::{
        str::FromStr,
        error::Error,
    },
};
#[derive(Parser)]
#[grammar = "grammar/sio_visa.pest"]
pub struct SioVisaParser;
/*
struct Visa;

impl FromStr for Visa {
    type Err = Box<dyn Error>;

    fn from_str(input: &str) -> Result<Self, Self::Err> {
        Self::from_raw(input)?
    }
}

impl<'de> Deserialize<'de> for Visa {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: Deserializer<'de>,
    {
        let s = String::deserialize(deserializer)?;
        FromStr::from_str(&s).map_err(de::Error::custom)
    }
}
*/
#[cfg(test)]
mod parse_tests {
    use super::*;

    #[test]
    fn instruction_test() {
        use std::fs;
        let unparsed_file = fs::read_to_string("examples/instruction_test.siov").expect("cannot read file");
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

    #[test]
    fn process_test() {
        use std::fs;
        let unparsed_file = fs::read_to_string("examples/process.siov").expect("cannot read file");
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
