use alloc::fmt::Display;
use alloc::string::String;

#[derive(PartialEq, Debug, Clone)]
pub enum Token {
    LeftBracket,
    RightBracket,
    Comma,
    Slash,
    Url,
    Semicolon,
    Colon,
    ColonColon,
    Import,

    // Literals.
    Identifier(String),
    String(String),
    PublicKey(String),

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
    Url,
    Semicolon,
    Colon,
    ColonColon,
    Import,

    // Literals.
    Identifier,
    String,
    PublicKey,

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
            Token::PublicKey(_) => TokenKind::PublicKey,
            Token::Url => TokenKind::Url,
            Token::Semicolon => TokenKind::Semicolon,
            Token::Colon => TokenKind::Colon,
            Token::ColonColon => TokenKind::ColonColon,
            Token::Import => TokenKind::Import,
            Token::Identifier(_) => TokenKind::Identifier,
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
            TokenKind::Colon => "':'",
            TokenKind::ColonColon => "::",
            TokenKind::Identifier => "identifier",
            TokenKind::String => "string",
            TokenKind::PublicKey => "public_key",
            TokenKind::Url => "url",
            TokenKind::Import => "'import'",
            TokenKind::Eof => "<EOF>",
            TokenKind::UnterminatedString => "<Unterminated String>",
            TokenKind::Unknown => "<Unknown>",
        })
    }
}
