use {
    super::*,
    chumsky::prelude::*,
    internment::Intern,
};

#[derive(Copy, Clone, Debug, PartialEq, Eq, Hash)]
pub enum Delimiter {
    Paren,
    Brace,
}

#[derive(Copy, Clone, Debug, PartialEq, Eq, Hash)]
pub enum Op {
    Eq,
}

impl fmt::Display for Op {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Op::Eq => write!(f, "="),
        }
    }
}

#[derive(Copy, Clone, Debug, PartialEq, Hash, Eq)]
pub enum Token {
    Skip,
    Char(char),
    Nat(u64),
    Bool(bool),
    Str(Intern<String>),
    Open(Delimiter),
    Close(Delimiter),
    TermIdent(ast::Ident),
    Let,
    In,
    Comma,
    Separator,
    Colon,
    Op(Op),
}

impl fmt::Display for Token {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Token::Nat(x) => write!(f, "{}", x),
            Token::Skip => write!(f, "skip"),
            Token::Let => write!(f, "let"),
            Token::In => write!(f, "in"),
            Token::Char(c) => write!(f, "{}", c),
            Token::Bool(x) => write!(f, "{}", x),
            Token::Str(s) => write!(f, "{}", s),
            Token::Open(Delimiter::Brace) => write!(f, "{{"),
            Token::Close(Delimiter::Brace) => write!(f, "}}"),
            Token::Open(Delimiter::Paren) => write!(f, "("),
            Token::Close(Delimiter::Paren) => write!(f, ")"),
            Token::TermIdent(identifier) => write!(f, "{}", identifier),
            Token::Comma => write!(f, ","),
            Token::Separator=> write!(f, "::"),
            Token::Colon=> write!(f, ":"),
            Token::Op(op) => write!(f, "{}", op),
        }
    }
}

pub fn lexer() -> impl Parser<char, Vec<(Token, Span)>, Error = Error> {
    let nat = text::int(10)
        .map(|s: String| Token::Nat(s.parse().unwrap()));

    let ctrl = just(',').to(Token::Comma)
        .or(just("::").to(Token::Separator))
        .or(just(":").to(Token::Colon));

    let op = just("=").to(Op::Eq)
        .map(Token::Op);

    let delim = just('{').to(Token::Open(Delimiter::Brace))
        .or(just('}').to(Token::Close(Delimiter::Brace)))
        .or(just('(').to(Token::Open(Delimiter::Paren))
        .or(just(')').to(Token::Close(Delimiter::Paren))));

    let escape = just('\\')
        .ignore_then(just('\\')
        .or(just('/'))
        .or(just('"'))
        .or(just('b').to('\x08'))
        .or(just('f').to('\x0C'))
        .or(just('n').to('\n'))
        .or(just('r').to('\r'))
        .or(just('t').to('\t')));

    let r#char = just('\'')
        .ignore_then(filter(|c| *c != '\\' && *c != '\'').or(escape))
        .then_ignore(just('\''))
        .map(Token::Char)
        .labelled("character");

    let string = just('"')
        .ignore_then(filter(|c| *c != '\\' && *c != '"').or(escape).repeated())
        .then_ignore(just('"'))
        .collect::<String>()
        .map(Intern::new)
        .map(Token::Str)
        .labelled("string");

    let word = text::ident().map(|s: String| match s.as_str() {
        "skip" => Token::Skip,
        "let" => Token::Let,
        "in" => Token::In,
        "true" => Token::Bool(true),
        "false" => Token::Bool(false),
        _ => Token::TermIdent(ast::Ident::new(s)),
    });

    let comment = just("//").then(take_until(just('\n'))).padded();

    let token = ctrl
        .or(word)
        .or(nat)
        .or(op)
        .or(delim)
        .or(string)
        .or(r#char)
        .map_with_span(move |token, span| (token, span))
        .padded()
        .recover_with(skip_then_retry_until([]));

    token
        .padded_by(comment.repeated())
        .repeated()
        .padded()
        .then_ignore(end())}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn simple() {
        let code = "
        let x in {
            skip
            x = 42
            (true)
            false
            record { atom1 : var1, atom2: var2 }
            named_procedure :: ( y ) { s }
            ( t ) { m } // anonymous procedure and a demonstrated comment not scanned
        }";
        let len = code.chars().count();

        let span = |i| Span::new(SrcId::empty(), i..i + 1);

        assert_eq!(
            lexer()
                .parse(chumsky::Stream::from_iter(
                    span(len),
                    code.chars().enumerate().map(|(i, c)| (c, span(i))),
                ))
                .map(|tokens| tokens.into_iter().map(|(tok, _)| tok).collect::<Vec<_>>()),
            Ok(vec![
                Token::Let,
                Token::TermIdent(ast::Ident::new("x")),
                Token::In,
                Token::Open(Delimiter::Brace),
                Token::Skip,
                Token::TermIdent(ast::Ident::new("x")),
                Token::Op(Op::Eq),
                Token::Nat(42),
                Token::Open(Delimiter::Paren),
                Token::Bool(true),
                Token::Close(Delimiter::Paren),
                Token::Bool(false),
                Token::TermIdent(ast::Ident::new("record")),
                Token::Open(Delimiter::Brace),
                Token::TermIdent(ast::Ident::new("atom1")),
                Token::Colon,
                Token::TermIdent(ast::Ident::new("var1")),
                Token::Comma,
                Token::TermIdent(ast::Ident::new("atom2")),
                Token::Colon,
                Token::TermIdent(ast::Ident::new("var2")),
                Token::Close(Delimiter::Brace),
                Token::TermIdent(ast::Ident::new("named_procedure")),
                Token::Separator,
                Token::Open(Delimiter::Paren),
                Token::TermIdent(ast::Ident::new("y")),
                Token::Close(Delimiter::Paren),
                Token::Open(Delimiter::Brace),
                Token::TermIdent(ast::Ident::new("s")),
                Token::Close(Delimiter::Brace),
                Token::Open(Delimiter::Paren),
                Token::TermIdent(ast::Ident::new("t")),
                Token::Close(Delimiter::Paren),
                Token::Open(Delimiter::Brace),
                Token::TermIdent(ast::Ident::new("m")),
                Token::Close(Delimiter::Brace),
                Token::Close(Delimiter::Brace),
            ]),
        );
    }
}
