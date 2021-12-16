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
    RFlow,
    Less,
    More,
}

impl fmt::Display for Op {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Op::Eq => write!(f, "="),
            Op::RFlow => write!(f, "=>"),
            Op::Less => write!(f, "<"),
            Op::More => write!(f, ">"),
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
    Wildcard,
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
            Token::Wildcard => write!(f, "_"),
        }
    }
}

pub fn lexer() -> impl Parser<char, Vec<(Token, Span)>, Error = Error> {
    let nat = text::int(10)
        .map(|s: String| Token::Nat(s.parse().unwrap()));

    let ctrl = just(',').to(Token::Comma)
        .or(just("::").to(Token::Separator))
        .or(just(":").to(Token::Colon));

    let op = just("=>").to(Op::RFlow)
        .or(just('=').to(Op::Eq))
        .or(just('<').to(Op::Less))
        .or(just('>').to(Op::More))
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
        "_" => Token::Wildcard,
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
let
    result: String,
    is_detected: Bool,
in {
    skip
    ligo: Data<Atom, Bool> {
        ngc4992 : false,
        ngc4993 : true,
        ngc4994 : true,
        ngc4995 : false,
    }                                                                   // record of galaxies https://en.wikipedia.org/wiki/New_General_Catalogue
    collision_detection := (l: Data<Atom, Bool>, g: Atom, o: String) {  // anonymous procedure
        ligo { g : is_detected } = l                                    // destructuring
        match is_detected {                                             // pattern matching
            true  => { o := \"detected\" },
            false => { o := \"not detected\" },
        }
    }
    collision_detected(ligo, ngc4993, result)
    print(result)
}
        ";
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
                Token::TermIdent(ast::Ident::new("result")),
                Token::Colon,
                Token::TermIdent(ast::Ident::new("String")),
                Token::Comma,
                Token::TermIdent(ast::Ident::new("is_detected")),
                Token::Colon,
                Token::TermIdent(ast::Ident::new("Bool")),
                Token::Comma,
                Token::In,
                Token::Open(Delimiter::Brace),
                Token::Skip,
                Token::TermIdent(ast::Ident::new("ligo")),
                Token::Colon,
                Token::TermIdent(ast::Ident::new("Data")),
                Token::Op(Op::Less),
                Token::TermIdent(ast::Ident::new("Atom")),
                Token::Comma,
                Token::TermIdent(ast::Ident::new("Bool")),
                Token::Op(Op::More),
                Token::Open(Delimiter::Brace),
                Token::TermIdent(ast::Ident::new("ngc4992")),
                Token::Colon,
                Token::Bool(false),
                Token::Comma,
                Token::TermIdent(ast::Ident::new("ngc4993")),
                Token::Colon,
                Token::Bool(true),
                Token::Comma,
                Token::TermIdent(ast::Ident::new("ngc4994")),
                Token::Colon,
                Token::Bool(true),
                Token::Comma,
                Token::TermIdent(ast::Ident::new("ngc4995")),
                Token::Colon,
                Token::Bool(false),
                Token::Comma,
                Token::Close(Delimiter::Brace),
                Token::TermIdent(ast::Ident::new("collision_detection")),
                Token::Colon,
                Token::Op(Op::Eq),
                Token::Open(Delimiter::Paren),
                Token::TermIdent(ast::Ident::new("l")),
                Token::Colon,
                Token::TermIdent(ast::Ident::new("Data")),
                Token::Op(Op::Less),
                Token::TermIdent(ast::Ident::new("Atom")),
                Token::Comma,
                Token::TermIdent(ast::Ident::new("Bool")),
                Token::Op(Op::More),
                Token::Comma,
                Token::TermIdent(ast::Ident::new("g")),
                Token::Colon,
                Token::TermIdent(ast::Ident::new("Atom")),
                Token::Comma,
                Token::TermIdent(ast::Ident::new("o")),
                Token::Colon,
                Token::TermIdent(ast::Ident::new("String")),
                Token::Close(Delimiter::Paren),
                Token::Open(Delimiter::Brace),
                Token::TermIdent(ast::Ident::new("ligo")),
                Token::Open(Delimiter::Brace),
                Token::TermIdent(ast::Ident::new("g")),
                Token::Colon,
                Token::TermIdent(ast::Ident::new("is_detected")),
                Token::Close(Delimiter::Brace),
                Token::Op(Op::Eq),
                Token::TermIdent(ast::Ident::new("l")),
                Token::TermIdent(ast::Ident::new("match")),
                Token::TermIdent(ast::Ident::new("is_detected")),
                Token::Open(Delimiter::Brace),
                Token::Bool(true),
                Token::Op(Op::RFlow),
                Token::Open(Delimiter::Brace),
                Token::TermIdent(ast::Ident::new("o")),
                Token::Colon,
                Token::Op(Op::Eq),
                Token::Str(Intern::from("detected")),
                Token::Close(Delimiter::Brace),
                Token::Comma,
                Token::Bool(false),
                Token::Op(Op::RFlow),
                Token::Open(Delimiter::Brace),
                Token::TermIdent(ast::Ident::new("o")),
                Token::Colon,
                Token::Op(Op::Eq),
                Token::Str(Intern::from("not detected")),
                Token::Close(Delimiter::Brace),
                Token::Comma,
                Token::Close(Delimiter::Brace),
                Token::Close(Delimiter::Brace),
                Token::TermIdent(ast::Ident::new("collision_detected")),
                Token::Open(Delimiter::Paren),
                Token::TermIdent(ast::Ident::new("ligo")),
                Token::Comma,
                Token::TermIdent(ast::Ident::new("ngc4993")),
                Token::Comma,
                Token::TermIdent(ast::Ident::new("result")),
                Token::Close(Delimiter::Paren),
                Token::TermIdent(ast::Ident::new("print")),
                Token::Open(Delimiter::Paren),
                Token::TermIdent(ast::Ident::new("result")),
                Token::Close(Delimiter::Paren),
                Token::Close(Delimiter::Brace),
            ]),
        );
    }
}
