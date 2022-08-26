use std::io::Cursor;

use regex::Regex;
use pest::Parser;


fn parse_expects(source: &str, regex: Regex, field: usize) -> Vec<String> {
    let mut results = vec![];
    for line in source.lines() {
        let caps = regex.captures(line);
        if let Some(caps) = caps {
            results.push(caps[field].to_owned());
        }
    }

    results
}

#[derive(Parser)]
#[grammar = "../../grammar.pest"]
pub struct SioParser;

#[derive(PartialEq, Debug)]
enum TestResult {
    Ok,
    CompileError,
    RuntimeError,
}

fn harness(source: &str) {
    let expects = parse_expects(source, Regex::new(r"// expect: ?(.*)").unwrap(), 1);
    let parsed = SioParser::parse(Rule::main, &source);
    match parsed {
        Ok(mut res) => {
            for statement in res.next().unwrap().into_inner() {
                match statement.as_rule() {
                    Rule::decl => {
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

    let expected_result =
        if !parse_expects(source, Regex::new(r"\[line (\d+)\] (Error.+)").unwrap(), 2).is_empty() {
            TestResult::CompileError
        } else if !parse_expects(source, Regex::new(r"// (Error.*)").unwrap(), 1).is_empty() {
            TestResult::CompileError
        } else if !parse_expects(
            source,
            Regex::new(r"// expect runtime error: (.+)").unwrap(),
            1,
        )
        .is_empty()
        {
            TestResult::RuntimeError
        } else {
            TestResult::Ok
        };

    //assert_eq!(expects, output);
    //assert_eq!(expected_result, result);
}

mod block {
    use super::harness;

    #[test]
    fn empty() {
        harness(include_str!("block/empty.sio"));
    }
/*
    #[test]
    fn scope() {
        harness(include_str!("block/scope.sio"));
    }
*/
}
mod r#if {
    use super::harness;

    #[test]
    fn r#if() {
        harness(include_str!("if/if.sio"));
    }
}

mod thread {
    use super::harness;

    #[test]
    fn thread() {
        harness(include_str!("thread/thread.sio"));
    }
}

mod module {
    use super::harness;

    #[test]
    fn module() {
        harness(include_str!("module/module.sio"));
    }
}
/*
mod function {
    use super::harness;

    #[test]
    fn anonymous_eager_no_return_no_args() {
        harness(include_str!("function/anonymous_eager_no_return_no_args.sio"));
    }

    #[test]
    fn anonymous_lazy_no_return_no_args() {
        harness(include_str!("function/anonymous_lazy_no_return_no_args.sio"));
    }

    #[test]
    fn private_eager_no_return_no_args() {
        harness(include_str!("function/private_eager_no_return_no_args.sio"));
    }

    #[test]
    fn private_lazy_no_return_no_args() {
        harness(include_str!("function/private_lazy_no_return_no_args.sio"));
    }

    #[test]
    fn public_eager_no_return_no_args() {
        harness(include_str!("function/public_eager_no_return_no_args.sio"));
    }

    #[test]
    fn public_lazy_no_return_no_args() {
        harness(include_str!("function/public_lazy_no_return_no_args.sio"));
    }
}
*/
