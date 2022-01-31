extern crate pest;
#[macro_use]
extern crate pest_derive;

use pest::Parser;

#[derive(Parser)]
#[grammar = "grammar/sio.pest"]
pub struct SioParser;


fn main() {
    let unparsed_file =
r#"
mod list {
  name2 :: () -> {I64: Hi} {
    hi = {1:2}
  }
}
"#;

    let file = SioParser::parse(Rule::main, &unparsed_file)
        .expect("unsuccessful parse") // unwrap the parse result
        .next().unwrap(); // get and unwrap the `file` rule; never fails

    for statement in file.into_inner() {
        match statement.as_rule() {
            Rule::variable_creation => {
                println!("got it! {:#?}", statement);
            }
            _ => (),
        }
    }
}
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn module_def_test() {
        let input =
        r#"
        mod list {
          name2 :: () -> {I64: Hi} {
            hi = {1:2}
          }
          raw name2 :: () -> {I64: Hi} {
            hi = {1:2}
          }
          draft name2 :: () -> {I64: Hi} {
            hi = {1:2}
          }
          stable name2 :: () -> {I64: Hi} {
            hi = {1:2}
          }
          deprecated name2 :: () -> {I64: Hi} {
            hi = {1:2}
          }
          legacy name2 :: () -> {I64: Hi} {
            hi = {1:2}
          }
        }
        "#;

        let parsed = SioParser::parse(Rule::main, &input);
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
                println!("{:#?}", e);
                panic!()
            }
        }
    }

    #[test]
    fn pattern_match_test() {
        let input =
        r#"
        let {
            data MyVariant = MyVariant
            data MyArray  = [| 3; ArrayElement |]
            data MyList   = [ ListElement ]
            data MyTuple  = ( TupleElement1, TupleElement2)
            data MySet    = < SetElement >
            data MyRecord = {
                Atom: [| 4; RecordElement1 |],
                Bool: [ RecordElement2 ],
                I64:  < RecordElement3 >,
                String: RecordElement4 ,
                Char: [ RecordElement5 ]
            }
            my_record: MyRecord
        } in {
            skip
            hi1 = hi2
        }
        "#;

        let parsed = SioParser::parse(Rule::main, &input);
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
                println!("{:#?}", e);
                panic!()
            }
        }
    }

    #[test]
    fn data_variant_test() {
        let input =
        r#"
        let {
            data MyArray  = [| 3; ArrayElement |]
            data MyList   = [ ListElement ]
            data MyTuple  = ( TupleElement1, TupleElement2)
            data MySet    = < SetElement >
            data MyRecord = {
                Atom: [| 4; RecordElement1 |],
                Bool: [ RecordElement2 ],
                I64:  < RecordElement3 >,
                String: RecordElement4 ,
                Char: [ RecordElement5 ]
            }
            data T = A
            data T = B(Bool)
            data T = C(I64, String)
            data T =
                | A
                | B
                | C
                | D
            data T =
                | A({I64: String, String: I64}, I64)
                | B([String], I64)
                | C(<String>, String)
                | D([|3; String|])
                | E((Tuple, Tuple2), (Tuple3, Tuple4))
            data Option<T> =
                | Some(T)
                | None
            data Result<T, E> =
                | Ok(T)
                | Err(E)
            data Test<T> = Test(T)
            hi: T
            option1: Option<I64>
            option2: Option<I64>
            result1: Result<I64, String>
            result2: Result<I64, String>
        } in {
            skip
            option1 = None
            option2 = Some(3)
            result1 = Ok(3)
            result2 = Err("darn")
        }
        "#;

        let parsed = SioParser::parse(Rule::main, &input);
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
                println!("{:#?}", e);
                panic!()
            }
        }
    }
}
