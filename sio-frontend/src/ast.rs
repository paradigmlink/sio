use alloc::string::String;
use alloc::vec::Vec;
use alloc::boxed::Box;

use crate::position::WithSpan;

pub type Identifier = String;

#[derive(Debug, PartialEq, Copy, Clone)]
pub enum UnaryOperator {
    Bang,
    Minus,
}

#[derive(Debug, PartialEq, Copy, Clone)]
pub enum BinaryOperator {
    Slash,
    Star,
    Plus,
    Minus,
    Greater,
    GreaterEqual,
    Less,
    LessEqual,
    BangEqual,
    EqualEqual,
}

#[derive(Debug, PartialEq, Copy, Clone)]
pub enum LogicalOperator {
    And,
    Or,
}

#[derive(Debug, PartialEq, Clone)]
pub enum Expr {
    Binary(Box<WithSpan<Expr>>, WithSpan<BinaryOperator>, Box<WithSpan<Expr>>),
    Grouping(Box<WithSpan<Expr>>),
    Number(f64),
    Boolean(bool),
    Nil,
    String(String),
    Call(Box<WithSpan<Expr>>, Vec<WithSpan<Expr>>),
    Unary(WithSpan<UnaryOperator>, Box<WithSpan<Expr>>),
    Variable(WithSpan<Identifier>),
    Logical(Box<WithSpan<Expr>>, WithSpan<LogicalOperator>, Box<WithSpan<Expr>>),
    Assign(WithSpan<Identifier>, Box<WithSpan<Expr>>),
    Get(Box<WithSpan<Expr>>, WithSpan<Identifier>),
    Set(Box<WithSpan<Expr>>, WithSpan<Identifier>, Box<WithSpan<Expr>>),
    List(Vec<WithSpan<Expr>>),
    ListGet(Box<WithSpan<Expr>>, Box<WithSpan<Expr>>),
    ListSet(Box<WithSpan<Expr>>, Box<WithSpan<Expr>>, Box<WithSpan<Expr>>),
}
#[derive(Debug, PartialEq, Clone)]
pub enum Stmt {
    Url(Box<WithSpan<Identifier>>, Vec<WithSpan<Identifier>>),
    Expression(Box<WithSpan<Expr>>),
    Print(Box<WithSpan<Expr>>),
    If(Box<WithSpan<Expr>>, Box<WithSpan<Stmt>>, Option<Box<WithSpan<Stmt>>>),
    Block(Vec<WithSpan<Stmt>>),
    Let(WithSpan<Identifier>, Option<Box<WithSpan<Expr>>>),
    Function(WithSpan<Identifier>, Vec<WithSpan<Identifier>>, Vec<WithSpan<Stmt>>),
    Use(WithSpan<String>, Option<Vec<WithSpan<String>>>),
}

pub type Ast = Vec<WithSpan<Stmt>>;
