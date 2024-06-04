#![no_std]

extern crate alloc;
extern crate proc_macro;

use alloc::vec::Vec;

pub mod position;
pub mod ast;

#[macro_use]
mod parser;
mod common;
mod token;
mod tokenizer;
mod stmt_parser;
mod expr_parser;

use werbolg_ir_write::module;
use werbolg_lang_common::{FileUnit, ParseError};
use ast::Ast;
use position::Diagnostic;

fn parse(code: &str) -> Result<Ast, Vec<Diagnostic>> {
    use stmt_parser::parse;
    use tokenizer::tokenize_with_context;
    let tokens = tokenize_with_context(code);
    let mut parser = crate::parser::Parser::new(&tokens);
    match parse(&mut parser) {
        Ok(ast) if parser.diagnostics().is_empty() => Ok(ast),
        Ok(_) => Err(parser.diagnostics().to_vec()),
        Err(_) => Err(parser.diagnostics().to_vec()),
    }
}

#[allow(dead_code)]
pub fn module(file_unit: &FileUnit) -> Result<werbolg_core::Module, Vec<Diagnostic>> {
    let ast = parse(&file_unit.content)?;
    Ok(module! {
        fn main() {
            1
        }
    })
}



#[cfg(test)]
mod tests {
    use alloc::vec::Vec;
    use alloc::vec;
    use alloc::string::ToString;
    use crate::token::Token;
    fn tokenize(buf: &str) -> Vec<Token> {
        use crate::tokenizer::tokenize_with_context;
        tokenize_with_context(buf)
            .iter()
            .map(|tc| tc.value.clone())
            .collect()
    }
    static SRC: &str =
        "corporal corp::Corporal {
            pub main :: () {
                let x;
                thread {
                  x = 0;
                }
                if x == 0 {
                  true
                } else {
                  false
                }
            }
        }";
    #[test]
    fn test() {
        assert_eq!(tokenize(&SRC ), vec![
                Token::Corporal,
                Token::Identifier("corp".to_string()),
                Token::ColonColon,
                Token::Identifier("Corporal".to_string()),
                Token::LeftBrace,
                Token::Pub,
                Token::Identifier("main".to_string()),
                Token::ColonColon,
                Token::LeftParen,
                Token::RightParen,
                Token::LeftBrace,
                Token::Let,
                Token::Identifier("x".to_string()),
                Token::Semicolon,
                Token::Thread,
                Token::LeftBrace,
                Token::Identifier("x".to_string()),
                Token::Equal,
                Token::Number(0.0),
                Token::Semicolon,
                Token::RightBrace,
                Token::If,
                Token::Identifier("x".to_string()),
                Token::EqualEqual,
                Token::Number(0.0),
                Token::LeftBrace,
                Token::True,
                Token::RightBrace,
                Token::Else,
                Token::LeftBrace,
                Token::False,
                Token::RightBrace,
                Token::RightBrace,
                Token::RightBrace,
            ]
        );
    }
}
