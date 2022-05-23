extern crate pest;
#[macro_use]
extern crate pest_derive;
pub use {
    pest::Parser,
};

#[derive(Parser)]
#[grammar = "grammar/sio_frontend.pest"]
pub struct SioParser;

#[cfg(test)]
mod parse_tests {
    use super::*;

    #[test]
    fn data_variant_test() {
        use std::fs;
        let unparsed_file = fs::read_to_string("examples/data_variant_test.sio").expect("cannot read file");
        let parsed = SioParser::parse(Rule::main, &unparsed_file);
        match parsed {
            Ok(mut res) => {
                for statement in res.next().unwrap().into_inner() {
                    match statement.as_rule() {
                        Rule::variable_creation => {
                            println!("{:#?}", statement);
                        }
                        _ => (),
                    }
                }
            },
            Err(e) => {
                println!("{}", e.to_string());
                panic!()
            }
        }
    }

    #[test]
    fn pattern_match_test() {
        use std::fs;
        let unparsed_file = fs::read_to_string("examples/pattern_match_test.sio").expect("cannot read file");
        let parsed = SioParser::parse(Rule::main, &unparsed_file);
        match parsed {
            Ok(mut res) => {
                for statement in res.next().unwrap().into_inner() {
                    match statement.as_rule() {
                        Rule::variable_creation => {
                            println!("{:#?}", statement);
                        }
                        _ => (),
                    }
                }
            },
            Err(e) => {
                println!("{}", e.to_string());
                panic!()
            }
        }
    }

    #[test]
    fn capitalized_record_key_test() {
        use std::fs;
        let unparsed_file = fs::read_to_string("examples/capitalized_record_key_test.sio").expect("cannot read file");
        let parsed = SioParser::parse(Rule::main, &unparsed_file);
        match parsed {
            Ok(mut res) => {
                for statement in res.next().unwrap().into_inner() {
                    match statement.as_rule() {
                        Rule::variable_creation => {
                            println!("{:#?}", statement);
                        }
                        _ => (),
                    }
                }
            },
            Err(e) => {
                println!("{}", e.to_string());
                panic!()
            }
        }
    }

    #[test]
    fn var_to_var_binding_test() {
        use std::fs;
        let unparsed_file = fs::read_to_string("examples/var_to_var_binding_test.sio").expect("cannot read file");
        let parsed = SioParser::parse(Rule::main, &unparsed_file);
        match parsed {
            Ok(mut res) => {
                for statement in res.next().unwrap().into_inner() {
                    match statement.as_rule() {
                        Rule::variable_creation => {
                            println!("{:#?}", statement);
                        }
                        _ => (),
                    }
                }
            },
            Err(e) => {
                println!("{}", e.to_string());
                panic!()
            }
        }
    }

    #[test]
    fn print_test() {
        use std::fs;
        let unparsed_file = fs::read_to_string("examples/print_test.sio").expect("cannot read file");
        let parsed = SioParser::parse(Rule::main, &unparsed_file);
        match parsed {
            Ok(mut res) => {
                for statement in res.next().unwrap().into_inner() {
                    match statement.as_rule() {
                        Rule::variable_creation => {
                            println!("{:#?}", statement);
                        }
                        _ => (),
                    }
                }
            },
            Err(e) => {
                println!("{}", e.to_string());
                panic!()
            }
        }
    }

    #[test]
    fn return_value_test() {
        use std::fs;
        let unparsed_file = fs::read_to_string("examples/return_value_test.sio").expect("cannot read file");
        let parsed = SioParser::parse(Rule::main, &unparsed_file);
        match parsed {
            Ok(mut res) => {
                for statement in res.next().unwrap().into_inner() {
                    match statement.as_rule() {
                        Rule::module_def => {
                            println!("{:#?}", statement);
                        }
                        _ => (),
                    }
                }
            },
            Err(e) => {
                println!("{}", e.to_string());
                panic!()
            }
        }
    }

    #[test]
    fn module_def_test() {
        use std::fs;
        let unparsed_file = fs::read_to_string("examples/module_def_test.sio").expect("cannot read file");
        let parsed = SioParser::parse(Rule::main, &unparsed_file);
        match parsed {
            Ok(mut res) => {
                for statement in res.next().unwrap().into_inner() {
                    match statement.as_rule() {
                        Rule::variable_creation => {
                            println!("{:#?}", statement);
                        }
                        _ => (),
                    }
                }
            },
            Err(e) => {
                println!("{}", e.to_string());
                panic!()
            }
        }
    }

    #[test]
    fn selective_receive_and_send_test() {
        use std::fs;
        let unparsed_file = fs::read_to_string("examples/selective_receive_and_send_test.sio").expect("cannot read file");
        let parsed = SioParser::parse(Rule::main, &unparsed_file);
        match parsed {
            Ok(mut res) => {
                for statement in res.next().unwrap().into_inner() {
                    match statement.as_rule() {
                        Rule::module_def => {
                            println!("{:#?}", statement);
                        }
                        _ => (),
                    }
                }
            },
            Err(e) => {
                println!("{}", e.to_string());
                panic!()
            }
        }
    }

    #[test]
    fn generic_procedure_test() {
        use std::fs;
        let unparsed_file = fs::read_to_string("examples/generic_procedure_test.sio").expect("cannot read file");
        let parsed = SioParser::parse(Rule::main, &unparsed_file);
        match parsed {
            Ok(mut res) => {
                for statement in res.next().unwrap().into_inner() {
                    match statement.as_rule() {
                        Rule::module_def => {
                            println!("{:#?}", statement);
                        }
                        _ => (),
                    }
                }
            },
            Err(e) => {
                println!("{}", e.to_string());
                panic!()
            }
        }
    }

    #[test]
    fn process_spawn_test() {
        use std::fs;
        let unparsed_file = fs::read_to_string("examples/process_spawn_test.sio").expect("cannot read file");
        let parsed = SioParser::parse(Rule::main, &unparsed_file);
        match parsed {
            Ok(mut res) => {
                for statement in res.next().unwrap().into_inner() {
                    match statement.as_rule() {
                        Rule::module_def => {
                            println!("{:#?}", statement);
                        }
                        _ => (),
                    }
                }
            },
            Err(e) => {
                println!("{}", e.to_string());
                panic!()
            }
        }
    }

    #[test]
    fn thread_test() {
        use std::fs;
        let unparsed_file = fs::read_to_string("examples/thread_test.sio").expect("cannot read file");
        let parsed = SioParser::parse(Rule::main, &unparsed_file);
        match parsed {
            Ok(mut res) => {
                for statement in res.next().unwrap().into_inner() {
                    match statement.as_rule() {
                        Rule::module_def => {
                            println!("{:#?}", statement);
                        }
                        _ => (),
                    }
                }
            },
            Err(e) => {
                println!("{}", e.to_string());
                panic!()
            }
        }
    }

    #[test]
    fn lazy_test() {
        use std::fs;
        let unparsed_file = fs::read_to_string("examples/lazy_test.sio").expect("cannot read file");
        let parsed = SioParser::parse(Rule::main, &unparsed_file);
        match parsed {
            Ok(mut res) => {
                for statement in res.next().unwrap().into_inner() {
                    match statement.as_rule() {
                        Rule::module_def => {
                            println!("{:#?}", statement);
                        }
                        _ => (),
                    }
                }
            },
            Err(e) => {
                println!("{}", e.to_string());
                panic!()
            }
        }
    }

    #[test]
    fn procedure_in_where_test() {
        use std::fs;
        let unparsed_file = fs::read_to_string("examples/procedure_in_where_test.sio").expect("cannot read file");
        let parsed = SioParser::parse(Rule::main, &unparsed_file);
        match parsed {
            Ok(mut res) => {
                for statement in res.next().unwrap().into_inner() {
                    match statement.as_rule() {
                        Rule::module_def => {
                            println!("{:#?}", statement);
                        }
                        _ => (),
                    }
                }
            },
            Err(e) => {
                println!("{}", e.to_string());
                panic!()
            }
        }
    }

    #[test]
    fn higher_order_procedure_test() {
        use std::fs;
        let unparsed_file = fs::read_to_string("examples/higher_order_procedure_test.sio").expect("cannot read file");
        let parsed = SioParser::parse(Rule::main, &unparsed_file);
        match parsed {
            Ok(mut res) => {
                for statement in res.next().unwrap().into_inner() {
                    match statement.as_rule() {
                        Rule::module_def => {
                            println!("{:#?}", statement);
                        }
                        _ => (),
                    }
                }
            },
            Err(e) => {
                println!("{}", e.to_string());
                panic!()
            }
        }
    }

    #[test]
    fn stack_test() {
        use std::fs;
        let unparsed_file = fs::read_to_string("examples/stack_test.sio").expect("cannot read file");
        let parsed = SioParser::parse(Rule::main, &unparsed_file);
        match parsed {
            Ok(mut res) => {
                for statement in res.next().unwrap().into_inner() {
                    match statement.as_rule() {
                        Rule::module_def => {
                            println!("{:#?}", statement);
                        }
                        _ => (),
                    }
                }
            },
            Err(e) => {
                println!("{}", e.to_string());
                panic!()
            }
        }
    }

    #[test]
    fn area_server_test() {
        use std::fs;
        let unparsed_file = fs::read_to_string("examples/area_server.sio").expect("cannot read file");
        let parsed = SioParser::parse(Rule::main, &unparsed_file);
        match parsed {
            Ok(mut res) => {
                for statement in res.next().unwrap().into_inner() {
                    match statement.as_rule() {
                        Rule::module_def => {
                            println!("{:#?}", statement);
                        }
                        _ => (),
                    }
                }
            },
            Err(e) => {
                println!("{}", e.to_string());
                panic!()
            }
        }
    }

    #[test]
    fn collection_operations_test() {
        use std::fs;
        let unparsed_file = fs::read_to_string("examples/collection_operations.sio").expect("cannot read file");
        let parsed = SioParser::parse(Rule::main, &unparsed_file);
        match parsed {
            Ok(mut res) => {
                for statement in res.next().unwrap().into_inner() {
                    match statement.as_rule() {
                        Rule::module_def => {
                            println!("{:#?}", statement);
                        }
                        _ => (),
                    }
                }
            },
            Err(e) => {
                println!("{}", e.to_string());
                panic!()
            }
        }
    }

    #[test]
    fn ffi_test() {
        use std::fs;
        let unparsed_file = fs::read_to_string("examples/ffi.sio").expect("cannot read file");
        let parsed = SioParser::parse(Rule::main, &unparsed_file);
        match parsed {
            Ok(mut res) => {
                for statement in res.next().unwrap().into_inner() {
                    match statement.as_rule() {
                        Rule::module_def => {
                            println!("{:#?}", statement);
                        }
                        _ => (),
                    }
                }
            },
            Err(e) => {
                println!("{}", e.to_string());
                panic!()
            }
        }
    }

    #[test]
    fn link_monitor_test() {
        use std::fs;
        let unparsed_file = fs::read_to_string("examples/link_monitor.sio").expect("cannot read file");
        let parsed = SioParser::parse(Rule::main, &unparsed_file);
        match parsed {
            Ok(mut res) => {
                for statement in res.next().unwrap().into_inner() {
                    match statement.as_rule() {
                        Rule::module_def => {
                            println!("{:#?}", statement);
                        }
                        _ => (),
                    }
                }
            },
            Err(e) => {
                println!("{}", e.to_string());
                panic!()
            }
        }
    }
    #[test]
    fn bin_hex_test() {
        use std::fs;
        let unparsed_file = fs::read_to_string("examples/binary_hexadecimal_test.sio").expect("cannot read file");
        let parsed = SioParser::parse(Rule::main, &unparsed_file);
        match parsed {
            Ok(mut res) => {
                for statement in res.next().unwrap().into_inner() {
                    match statement.as_rule() {
                        Rule::module_def => {
                            println!("{:#?}", statement);
                        }
                        _ => (),
                    }
                }
            },
            Err(e) => {
                println!("{}", e.to_string());
                panic!()
            }
        }
    }
    #[test]
    fn reaction_test() {
        use std::fs;
        let unparsed_file = fs::read_to_string("examples/reaction.sio").expect("cannot read file");
        let parsed = SioParser::parse(Rule::main, &unparsed_file);
        match parsed {
            Ok(mut res) => {
                for statement in res.next().unwrap().into_inner() {
                    match statement.as_rule() {
                        Rule::module_def => {
                            println!("{:#?}", statement);
                        }
                        _ => (),
                    }
                }
            },
            Err(e) => {
                println!("{}", e.to_string());
                panic!()
            }
        }
    }
}
