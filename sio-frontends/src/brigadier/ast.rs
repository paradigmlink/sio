use alloc::string::String;
use alloc::vec::Vec;

use crate::brigadier::position::WithSpan;

pub type Identifier = String;

#[derive(Debug, PartialEq, Clone)]
pub enum Stmt {
    Import(WithSpan<String>),
}

pub type Ast = Vec<WithSpan<Stmt>>;
