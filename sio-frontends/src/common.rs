use alloc::format;
use alloc::string::String;
use crate::{
    parser::Parser,
    position::WithSpan,
    token::{Token, TokenKind},
};

pub fn expect_string(p: &mut Parser) -> Result<WithSpan<String>, ()> {
    let token = p.advance();
    match &token.value {
        Token::String(ident) => Ok(WithSpan::new(ident.clone(), token.span)),
        _ => {
            p.error(&format!("Expected {} got {}", TokenKind::String, token.value), token.span);
            Err(())
        },
    }
}
