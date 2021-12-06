//#![allow(dead_code)]
//#![feature(bindings_after_at)]
//#[cfg(target_os = "hermit")]
//extern crate hermit_sys;
//use getrandom;
//use hermit_abi;
use chumsky::Parser;

mod parse;
mod eval;


fn main() {
    let src = "
        let three = 3;
        let eight = 5 + three;
        add :: (x y) {
            x + y
        };
        let eleven = add(three, eight);
        divide :: (k z) {
            k / z
        };
        divide(eleven, 11)
    ";

    match parse::parser().parse(src) {
        Ok(ast) => match eval::eval(&ast, &mut Vec::new(), &mut Vec::new()) {
            Ok(output) => println!("{}", output),
            Err(eval_err) => println!("Evaluation error: {}", eval_err),
        },
        Err(parse_errs) => parse_errs
            .into_iter()
            .for_each(|e| println!("Parse error: {:?}", e)),
    }
}
