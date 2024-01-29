#![no_std]

extern crate alloc;
extern crate proc_macro;

pub mod position;
pub mod ast;

mod common;
mod parser;
mod token;
mod tokenizer;
//mod stmt_parser;
//mod expr_parser;

use werbolg_ir_write::module;

#[allow(dead_code)]
pub fn module() -> werbolg_core::Module {
    module! {
        fn main() {
            1
        }
    }
}

