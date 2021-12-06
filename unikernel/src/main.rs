#![allow(dead_code)]
#![feature(bindings_after_at)]
#[cfg(target_os = "hermit")]
extern crate hermit_sys;
use {
    sio_vm::{self, Parser},
};

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

    match sio_vm::parser().parse(src) {
        Ok(ast) => match sio_vm::eval(&ast, &mut Vec::new(), &mut Vec::new()) {
            Ok(output) => println!("{}", output),
            Err(eval_err) => println!("Evaluation error: {}", eval_err),
        },
        Err(parse_errs) => parse_errs
            .into_iter()
            .for_each(|e| println!("Parse error: {:?}", e)),
    }
}
