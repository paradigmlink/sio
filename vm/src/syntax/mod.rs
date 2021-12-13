pub mod span;
pub mod node;
pub mod error;
pub mod ast;
pub mod src;
pub mod token;
pub mod parse;
pub use self::{
    error::{Error, ErrorKind},
    span::Span,
    node::{Node, SrcNode},
    src::SrcId,
    token::{Token, Delimiter},
};
use chumsky::prelude::*;
use std::fmt;

fn parse<T>(parser: impl parse::Parser<T>, code: &str, src: SrcId) -> (Option<T>, Vec<Error>) {
    let mut errors = Vec::new();

    let len = code.chars().count();
    let eoi = Span::new(src, len..len + 1);

    let (tokens, mut lex_errors) = token::lexer()
        .parse_recovery(chumsky::Stream::from_iter(
            eoi,
            code
                .chars()
                .enumerate()
                .map(|(i, c)| (c, Span::new(src, i..i + 1))),
        ));
    errors.append(&mut lex_errors);

    let tokens = if let Some(tokens) = tokens {
        tokens
    } else {
        return (None, errors);
    };

    let (output, mut parse_errors) = parser.parse_recovery(chumsky::Stream::from_iter(eoi, tokens.into_iter()));
    errors.append(&mut parse_errors);

    (output, errors)
}
