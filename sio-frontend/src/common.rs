use alloc::format;
use alloc::string::String;
use crate::alloc::string::ToString;
use crate::{
    ast::Identifier,
    parser::Parser,
    position::WithSpan,
    token::{Token, TokenKind},
};

pub fn expect_identifier(p: &mut Parser) -> Result<WithSpan<Identifier>, ()> {
    let token = p.advance();
    match &token.value {
        Token::Identifier(ident) => Ok(WithSpan::new(ident.clone(), token.span)),
        _ => {
            p.error(&format!("Expected {} got {}", TokenKind::Identifier, token.value), token.span);
            Err(())
        },
    }
}

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

pub fn expect_left_paren(p: &mut Parser) -> Result<WithSpan<String>, ()> {
    let token = p.advance();
    match &token.value {
        Token::LeftParen => Ok(WithSpan::new("(".to_string(), token.span)),
        _ => {
            p.error(&format!("Expected {} got {}", TokenKind::LeftParen, token.value), token.span);
            Err(())
        },
    }
}
