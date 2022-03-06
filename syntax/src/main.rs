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
mod 79f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03abd::/src/list 100 {
  name2 :: () -> {i64: Hi} {
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
mod parse_tests {
    use super::*;


    #[test]
    fn data_variant_test() {
        let input =
        r#"
       mod 79f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03abd::/src/area/server 100 {
            data DataType = Constructor
            data DataType = Constructor([i64], [i64])
            data DataType =
                | Constructor([i64], [i64])
                | Constructor([i64], [i64])
            data DataType = Sheep({name: bool, naked: bool})
            data DataType<A,B,C> = Constructor(Option<T>, Result<string, i64>)
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
                | sketch MyArray ([|3; Option<Result<i64, string>>|], i64)
                | stable MyList([Option<Result<i64, string>>], i64)
                | summon MyTuple((Option<Result<i64, string>>, i64))
                | sunset MySet(<Option<Result<i64, string>>>, i64)
                | seeyou MyRecord({
                    an_atom: [|2; i64|],
                    bool: [i64],
                    i64:  (i64),
                    string:<i64>,
                    char: {i64:Option<Result<i64, string>>}
                  })
            data F = MyRecord({
                an_atom: [|2; i64|],
                bool: [i64],
                i64:  (i64),
                string:<i64>,
                char: {i64:Option<Result<i64, string>>}
            })
            a: A
            b: B
            e_array: E
            e_list: E
            e_tuple: E
            e_set: E
            e_record: E
            f: F<i64>
            k_1: K<i64, bool>
            k_2: K<i64, bool>
            p_1: P<i64>
            p_2: P<Option<i64>>
            name0 :: () -> Simple {
                skip
                a = A
                b = C
                e_array = MyArray([|1,2,3|])
                e_list = MyList([1,2,3])
                e_tuple = MyTuple((1,2))
                e_tuple = (ident)
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
        mod 79f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03abd::/src/area/server 100 {
            name0 :: () -> Simple {
                match [|3|] {
                    | [first|second|tail] => { skip }
                    | [head|tail] => { skip }
                    | [||] => { skip }
                    | [] => { skip }
                    | true => { skip }
                    | false => { skip }
                    | 'h' => { skip }
                    | _ => { skip }
                    | "hello" => { skip }
                    | val: i64 => { skip }
                    | (val: i64, str: string) => { skip }
                    | Rectangle(hi) => { skip }
                    | Rectangle(width, height) => { skip }
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
    fn capitalized_record_key_test() {
        let input =
        r#"
        mod 79f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03abd::/src/area/server 100 {
            data Export = Export({ export_procedure: char, ExportType: char })
            summon name :: () -> string {
                hi = Export({export_procedure, ExportType})
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
        mod 79f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03abd::/src/area/server 100 {
            data Rec = Rec({ name: (), name: (A)->A })
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
                k = (hi: Hi, hi: Hi<i64>) -> Result<Option<i64>, string> { skip }
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
                    hi=3+3
                    hi=3*3
                    hi=3/3/3
                    hi=3-3
                    hi=3==3
                    hi=3<3
                    hi=3>3
                    hi=true||false
                    hi=true&&false
                    hi=3<=3
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
        mod 79f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03abd::/src/area/server 100 {
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
        mod 79f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03abd::/src/area/server 100 {
            summon name :: (str: string) -> string { skip x="string" }
            summon name :: () -> string { "string" }
            summon name :: () -> string { 32 }
            summon name :: () -> string { 32+32 }
            summon name :: () -> string { 32*32*32 }
            summon name :: () -> string { 32.42 }
            summon name :: () -> string { true }
            summon name :: () -> string { false }
            summon name :: () -> string { 'c' }
            summon name :: () -> string { (32,42) }
            summon name :: () -> string { <32,42> }
            summon name :: () -> string { {thirty_two: 32, fourty_two: 42} }
            summon name :: () -> string { [32, 42] }
            summon name :: () -> string { [|32, 42|] }
            summon name :: () -> string { Constructor }
            summon name :: () -> string { Constructor([32]) }
            summon name :: () -> string { Constructor([32], [32]) }
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
        mod 79f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03abd::/src/area/server 10000000 {
            use 9b397a7b41de899b986208961e34b09f52166315e1be0ac62e6aed2f854eb55b::{
                fun,
                Type,
                widget::{
                    fun,
                    Type,
                    wiget::{
                        fun,
                        Type,
                        wiget::{
                            fun,
                            Type,
                            wiget::{
                                fun,
                                Type,
                                wiget::{
                                    fun,
                                    Type,
                                    wiget::{
                                        fun,
                                        Type,
                                    }
                                }
                            }
                        }
                    }
                },
                widget::{
                    fun,
                    Type,
                    wiget::{
                        fun,
                        Type,
                        wiget::{
                            fun,
                            Type,
                        }
                    }
                }
            }
            use 9b397a7b41de899b986208961e34b09f52166315e1be0ac62e6aed2f854eb55b::{
                app1::{
                    mod1::{hi1, Type1},
                    mod2::{hi2, Type2},
                },
                app3::{
                    mod3::{hi3, Type3}
                },
            }
            use 4d018d92514612192d2cb602da12c4a8a56229e146ba5e2716b723c785a6a6ae::{
                app1::{
                    mod1::{hi1, Type1}
                }
            }
            data Sheep =
                | Version1 ({name: string, naked: bool})
                | Version2 ({name: string, naked: bool, breed: Breed})
            sketch data Sheep<I> = sketch Sheep({push: (I) -> Stack<I>, pop: ()->(I, Stack<I>), is_empty: bool})
            sketch data Sheep =
                | sketch Version1 ({name: string, naked: bool})
                | summon Version2 ({name: string, naked: bool, breed: Breed})
            summon data DataType = sketch Constructor
            sketch data DataType = sketch Constructor
            stable data DataType = stable Constructor
            sunset data DataType = sunset Constructor
            seeyou data DataType = seeyou Constructor
            name0 :: () -> Simple {
                hi = {1:2}
            }
            summon name1 :: () -> Generic<Simple> {
                hi = {1:2}
            }
            sketch name2 :: () -> {i64: Simple} {
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
                println!("{:#?}", e);
                panic!()
            }
        }
    }

    #[test]
    fn generic_function_test() {
        let input =
        r#"
        mod 79f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03abd::/src/area/server 100 {
            summon name :: () { skip }
            summon name :: (a: A) { skip }
            summon name<A> :: (a: A) -> A { skip }
            summon name<A,B> :: (a: A, b: B) -> (A, B) { skip }
            summon name<A,B,C> :: (a: A, b: B, c: C) -> (A, B, C) { skip }
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
    fn process_spawn_test() {
        let input =
        r#"
        mod 79f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03abd::/src/area/server 100 {
            summon name :: () {
                let pid1: Pid
                let pid2: Pid
                spawn(79f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03abd::/src/area/server, loop, [])
                pid1 = spawn(79f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03abd::/src/area/server, loop, [])
                pid2 = spawn(pid1, loop, [])
                register("process_name/name", identity)
                register(url_string, 79f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03abd::/src/area/server)
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

    #[test]
    fn thread_test() {
        let input =
        r#"
        mod 79f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03abd::/src/area/server 100 {
            summon name :: () {
                thread {
                    skip
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

    #[test]
    fn lazy_test() {
        let input =
        r#"
        mod 79f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03abd::/src/area/server 100 {
            summon lazy name :: () {
                skip
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

    #[test]
    fn procedure_in_where_test() {
        let input =
        r#"
        mod 79f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03abd::/src/area/server 100 {
            name :: () {
                skip
            } in {
                skip
            } where {
                skip
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

    #[test]
    fn higher_order_procedure_test() {
        let input =
        r#"
        mod 79f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03abd::/src/area/server 100 {
            name :: () -> {string:Hi} {
                skip
            }
            name :: (a: ()->Hi) {
                skip
            }
            name :: (a: (B)->Hi) {
                skip
            }
            name :: (a: (B)->Hi, b: (C)->Hi) {
                skip
            }
            name :: (a: ([B])->[Hi], b: (C)->[|3;Hi|]) {
                skip
            }
            name<A> :: (a: (A, A)->(A)->bool, b: (A, A)->(A)->Hi) -> Hi{
                skip
            }
            name<A,B,C> :: (
                a: (A, A) -> (C) -> bool,
                b: (A, B) -> (C) -> bool
            ) -> (A)->bool {
                skip
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

    #[test]
    fn stack_test() {
        let input =
        r#"
        mod 79f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03abd::/src/area/server 100 {
            sketch data Stack<I> = sketch Stack({ push: (I)->Stack<I>, pop: ()->(I, Stack<I>), is_empty: bool})
            stack<I> :: (inner_stack: [I]) -> Stack<I> {
                push :: (item: I) -> Stack<I> {
                    stack([item|stack])
                }
                pop :: () -> (I, Stack<I>) {
                    match inner_stack {
                        | [head|tail] => {(head, stack(tail))}
                    }
                }
                is_empty :: () -> bool {
                    inner_stack == []
                }
            } in {
                Stack({push, pop, is_empty})
            }
            sketch new_stack<I> :: () -> Stack<I> {
                stack([])
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
                println!("{:#?}", e);
                panic!()
            }
        }
    }

    #[test]
    fn collection_operations_test() {
        use std::fs;
        let unparsed_file = fs::read_to_string("examples/collection_operations.sio").expect("cannot read file");
        let parsed = SioParser::parse(Rule::main, &unparsed_file);
        println!("{:#?}", parsed);
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
