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
          name0 :: () -> Simple {
            hi = {1:2}
          }
          raw name1 :: () -> Generic<Simple> {
            hi = {1:2}
          }
          draft name2 :: () -> {I64: Simple} {
            hi = {1:2}
          }
          stable name3 :: () -> [Generic<Simple>] {
            hi = {1:2}
          }
          deprecated name4 :: () -> [|3; Hi|] {
            hi = {1:2}
          }
          legacy name5 :: () -> <Hi> {
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
            data DataType = Constructor
            data DataType<A,B,C> = Constructor(Option<T>, Result<String, I64>)
            data A =
                | C
                | D
            data E<I> = F(I)
            data Tree<T> =
                | None
                | Leaf(T)
                | Node(Tree<T>, Tree<T>)
            data Result<M, N> =
                | Ok(M)
                | Err(N)
            data Option<T> =
                | None
                | Some(T)
            data E =
                | MyArray([|3; Option<Result<I64, String>>|], I64)
                | MyList([Option<Result<I64, String>>], I64)
                | MyTuple((Option<Result<I64, String>>, I64))
                | MySet(<Option<Result<I64, String>>>, I64)
                | MyRecord({
                    Atom: [|2; I64|],
                    Bool: [I64],
                    I64:  (I64),
                    String:<I64>,
                    Char: {I64:Option<Result<I64, String>>}
                  })
            a: A
            b: B
            e_array: E
            e_list: E
            e_tuple: E
            e_set: E
            e_record: E
            f: F<I64>
            k_1: K<I64, Bool>
            k_2: K<I64, Bool>
            p_1: P<I64>
            p_2: P<Option<I65>>
        } in {
            skip
            a = A
            b = C
            e_array = MyArray([|1,2,3|])
            e_list = MyList([1,2,3])
            e_tuple = MyTuple((1,2))

            e_record = MyRecord({
                an_atom:[|1,2|],
                true:[1],
                2:<1>,
                "hi":1,
                '
                A
                '
                :
                [
                1
                ]
            })
            e_set = MySet(<2,3>)
            f = J(3)
            k_1 = N(3)
            k_2 = O(true)
            p_1 = R
            p_2 = S(3)
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
                Char: [ RecordElement5 ],
                Char: ( RecordElement6 )
            }
            data T = A
            data T = B(Bool)
            data T = C(I64, String)
            data A =
                | A
                | B
                | C
                | D
            data B =
                | A({I64: String, String: I64}, I64)
                | B([String], I64)
                | C(<String>, String)
                | D([|3; String|])
                | E((Tuple, Tuple2), (Tuple3, Tuple4))
            data Option<T> =
                | None
                | Some(T)
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
