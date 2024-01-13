#![no_std]
use werbolg_ir_write::module;

#[allow(dead_code)]
pub fn module() -> werbolg_core::Module {
    module! {
        fn main() {
            1
        }
    }
}

