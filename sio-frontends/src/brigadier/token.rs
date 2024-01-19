use alloc::fmt::Display;
use alloc::string::String;

#[derive(PartialEq, Debug, Clone)]
pub enum Token {
    LeftBracket,
    RightBracket,
    Comma,
    Slash,
    String(String),
    Semicolon,
    Import,

    // Other.
    Eof,
    UnterminatedString,
    Unknown(char),
}

#[derive(Copy, Clone, Debug, PartialEq)]
pub enum TokenKind {
    LeftBracket,
    RightBracket,
    Comma,
    Slash,
    String,
    Semicolon,
    Import,

    // Other.
    Eof,
    UnterminatedString,
    Unknown,
}

impl Display for Token {
    fn fmt(&self, f: &mut alloc::fmt::Formatter<'_>) -> alloc::fmt::Result {
        let kind: TokenKind = self.into();
        write!(f, "{}", kind)
    }
}

impl From<&crate::brigadier::position::WithSpan<Token>> for TokenKind {
    fn from(token_with_span: &crate::brigadier::position::WithSpan<Token>) -> Self {
        TokenKind::from(&token_with_span.value)
    }
}

impl From<&Token> for TokenKind {
    fn from(token: &Token) -> Self {
        match token {
            Token::LeftBracket => TokenKind::LeftBracket,
            Token::RightBracket => TokenKind::RightBracket,
            Token::Comma => TokenKind::Comma,
            Token::Slash => TokenKind::Slash,
            Token::String(_) => TokenKind::String,
            Token::Semicolon => TokenKind::Semicolon,
            Token::Import => TokenKind::Import,
            Token::Eof => TokenKind::Eof,
            Token::UnterminatedString => TokenKind::UnterminatedString,
            Token::Unknown(_) => TokenKind::Unknown,
        }
    }
}

impl Display for TokenKind {
    fn fmt(&self, f: &mut alloc::fmt::Formatter<'_>) -> alloc::fmt::Result {
        write!(f, "{}", match self {
            TokenKind::LeftBracket => "'['",
            TokenKind::RightBracket => "']'",
            TokenKind::Slash => "'/'",
            TokenKind::Comma => "','",
            TokenKind::Semicolon => "';'",
            TokenKind::String => "string",
            TokenKind::Import => "'import'",
            TokenKind::Eof => "<EOF>",
            TokenKind::UnterminatedString => "<Unterminated String>",
            TokenKind::Unknown => "<Unknown>",
        })
    }
}
