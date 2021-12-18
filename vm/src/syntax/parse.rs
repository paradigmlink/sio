
use super::*;

pub trait Parser<T> = chumsky::Parser<Token, T, Error = Error> + Clone;

pub fn literal_parser() -> impl Parser<ast::Literal> {
    filter_map(|span, token| match token {
        Token::Nat(x) => Ok(ast::Literal::Nat(x)),
        Token::Num(x) => Ok(ast::Literal::Num(x.parse().expect("Valid number could not be parsed as f64"))),
        Token::Bool(x) => Ok(ast::Literal::Bool(x)),
        Token::Char(x) => Ok(ast::Literal::Char(x)),
        Token::Str(x) => Ok(ast::Literal::Str(x)),
        token => Err(Error::expected_input_found(span, None, Some(token))),
    })
}

pub fn term_ident_parser() -> impl Parser<ast::Ident> {
    filter_map(|span, token| match token {
        Token::TermIdent(x) => Ok(x),
        token => Err(Error::expected_input_found(span, None, Some(token))),
    })
}

pub fn nested_parser<'a, T: 'a>(parser: impl Parser<T> + 'a, delimiter: Delimiter, f: impl Fn(Span) -> T + Clone + 'a) -> impl Parser<T> + 'a {
    parser
        .delimited_by(Token::Open(delimiter), Token::Close(delimiter))
        .recover_with(nested_delimiters(
            Token::Open(delimiter), Token::Close(delimiter),
            [
                (Token::Open(Delimiter::Paren), Token::Close(Delimiter::Paren)),
                (Token::Open(Delimiter::Brace), Token::Close(Delimiter::Brace)),
            ],
            f,
        ))
        .boxed()
}
