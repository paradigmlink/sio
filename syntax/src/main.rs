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
    fn data_variant_test() {
        let input =
        r#"
        mod app/mod _ {
            data DataType = Constructor
            data DataType = Constractor([Int], [Int])
            data DataType = Sheep({name: Bool, naked: Bool})
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
                | sketch MyArray ([|3; Option<Result<I64, String>>|], I64)
                | stable MyList([Option<Result<I64, String>>], I64)
                | summon MyTuple((Option<Result<I64, String>>, I64))
                | sunset MySet(<Option<Result<I64, String>>>, I64)
                | seeyou MyRecord({
                    an_atom: [|2; I64|],
                    Bool: [I64],
                    I64:  (I64),
                    String:<I64>,
                    Char: {I64:Option<Result<I64, String>>}
                  })
            data F = MyRecord({
                an_atom: [|2; I64|],
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
            name0 :: () -> Simple {
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
                    'A':[1]
                })
                e_set = MySet(<2,3>)
                e_sheep = Sheep({name: self.name, naked: true})
                f = J(3)
                k_1 = N(3)
                k_2 = O(true)
                p_1 = R
                p_2 = S(3)
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
        mod app/mod _ {
        } in {
            name0 :: () -> Simple {
                match [|3|] {
                | [||] => { skip }
                | [] => { skip }
                | true => { skip }
                | false => { skip }
                | 'h' => { skip }
                | _ => { skip }
                | "hello" => { skip }
                }
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
    fn var_to_var_binding_test() {
        let input =
        r#"
        mod app/mod _ {
        } in {
            name0 :: () -> Simple {
                a = Type
                b = Type(2)
                c = Type(true)
                d1 = "43"
                d2 = "43.43"
                e = true
                f = <3>
                g = ["hi"]
                h = [|3|]
                i = (Type("hi"),Type(3))
                j = false
                i = () { skip }
                k = () -> Hi { skip }
                k = (hi: Hi) -> Hi { skip }
                k = (hi: Hi, hi: Hi) -> Hi { skip }
                k = (hi: Hi, hi: Hi<I64>) -> Result<Option<I64>, String> { skip }
                k = (hi: [|3; Hi|], hi: [Hi]) -> <Hi> {
                        skip
                        hi=[|3,2,1|]
                        hi=[3,2,1]
                        hi=<3,2,1>
                        hi=(3,2,1)
                        hi="hi"
                        hi=3
                        hi=3.3
                        hi=true
                        hi=false
                        hi='h'
                        hi=(3+3)
                        hi=(3*3)
                        hi=(3/3)
                        hi=(3-3)
                        hi=(3==3)
                        hi=(3<3)
                        hi=(3>3)
                        hi=(true||false)
                        hi=(true&&false)
                        hi=(3<=3)
                        hi=((((((((3>=3)+3)/3)*3)-3)<=3)&&3)||3)
                    }
                l = Sheep({name: self.name, naked: true})
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
    fn print_test() {
        let input =
        r#"
        mod app/mod _ {
        } in {
            name0 :: () -> Simple {
                hi = {1:2}
                print("...")
                print("{} ...", self.name())
                print("{} ... {}", self.name, self.noise())
                print("{} ...", self.name())
                print("{} ...", name)
                print("{} ...", name())
                print("{} ...", 3)
                print("{} ...", "text")
                print("{} ...", true)
                println("{} ...", "text")
                println("...")
                println("{} ... {}", self.name, self.noise())
                println("{} ...", self.name())
                println("{} ...", name)
                println("{} ...", name())
                println("...")
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
    fn return_value_test() {
        let input =
        r#"
        mod app/mod _ {
        } in {
            summon name :: (str: String) -> String { skip x="string" }
            summon name :: () -> String { "string" }
            summon name :: () -> String { 32 }
            summon name :: () -> String { 32.42 }
            summon name :: () -> String { true }
            summon name :: () -> String { false }
            summon name :: () -> String { 'c' }
            summon name :: () -> String { (32,42) }
            summon name :: () -> String { <32,42> }
            summon name :: () -> String { {thirty_two: 32, fourty_two: 42} }
            summon name :: () -> String { [32, 42] }
            summon name :: () -> String { [|32, 42|] }
            summon name :: () -> String { Constructor }
            summon name :: () -> String { Constructor([32]) }
            summon name :: () -> String { Constructor([32], [32]) }
        }
        "#;

        let parsed = SioParser::parse(Rule::main, &input);
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
                println!("{:#?}", e);
                panic!()
            }
        }
    }

    #[test]
    fn module_def_test() {
        let input =
        r#"
        mod app/mod
        79f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03abd17ac4e3e3f23d094935d65f113f62c5d73e2fab8dc62a28fed4b6c1b9b7b830d {
            use 4d018d92514612192d2cb602da12c4a8a56229e146ba5e2716b723c785a6a6ae00b6a4a1c789ad2d6c8668bcf56dcb80e0adf1dc07b2a72e5dd65f1933b05003::{
                app1::{
                    mod1::{hi1, Type1}
                    mod2::{hi2, Type2}
                }
                app3::{
                    mod3::{hi3, Type3}
                }
            }
            use 879f8ba6106e519ac7b6e09cb7a0905f9c8e6c9779cd76e1ece709277aa2b97b2d576ae86dd6c93ceaf61100e7a06c75aa841758e8477be62089475c8a7af00c::{
                app1::{
                    mod1::{hi1, Type1}
                }
            }
            data Sheep =
                | Version1 ({name: String, naked: Bool})
                | Version2 ({name: String, naked: Bool, breed: Breed})
            sketch data Sheep =
                | sketch Version1 ({name: String, naked: Bool})
                | summon Version2 ({name: String, naked: Bool, breed: Breed})
            summon data DataType = sketch Constructor
            sketch data DataType = sketch Constructor
            stable data DataType = stable Constructor
            sunset data DataType = sunset Constructor
            seeyou data DataType = seeyou Constructor
        } in {
            name0 :: () -> Simple {
                hi = {1:2}
            }
            summon name1 :: () -> Generic<Simple> {
                hi = {1:2}
            }
            sketch name2 :: () -> {I64: Simple} {
                hi = {1:2}
            }
            stable name3 :: () -> [Generic<Simple>] {
                hi = {1:2}
            }
            sunset name4 :: () -> [|3; Hi|] {
                hi = {1:2}
            }
            seeyou name5 :: () -> <Hi> {
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
    fn selective_receive_and_send_test() {
        let input =
        r#"
        mod app/mod _ {
        } in {
            summon name :: (str: String) -> String {
                process ! "string"
                receive all {
                | [||] => { skip }
                | [] => { skip }
                | true => { skip }
                }
                receive proceess {
                | false => { skip }
                | 'h' => { skip }
                | _ => { skip }
                | "hello" => { skip }
                }
            }
        }
        "#;

        let parsed = SioParser::parse(Rule::main, &input);
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
                println!("{:#?}", e);
                panic!()
            }
        }
    }
}
