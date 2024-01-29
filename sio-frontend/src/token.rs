use alloc::fmt::Display;
use alloc::string::String;

#[derive(PartialEq, Debug, Clone)]
pub enum Token {
    LeftBracket,
    RightBracket,
    LeftBrace,
    RightBrace,
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

    // Keywords.
    Brigadier,
    Major,

    // Other.
    Eof,
    UnterminatedString,
    Unknown(char),
}

#[derive(Copy, Clone, Debug, PartialEq)]
pub enum TokenKind {
    LeftBracket,
    RightBracket,
    LeftBrace,
    RightBrace,
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

    // Keywords.
    Brigadier,
    Major,

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

impl From<&crate::position::WithSpan<Token>> for TokenKind {
    fn from(token_with_span: &crate::position::WithSpan<Token>) -> Self {
        TokenKind::from(&token_with_span.value)
    }
}

impl From<&Token> for TokenKind {
    fn from(token: &Token) -> Self {
        match token {
            Token::LeftBracket => TokenKind::LeftBracket,
            Token::RightBracket => TokenKind::RightBracket,
            Token::LeftBrace => TokenKind::LeftBrace,
            Token::RightBrace => TokenKind::RightBrace,
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
            Token::Brigadier => TokenKind::Brigadier,
            Token::Major => TokenKind::Major,
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
            TokenKind::LeftBrace => "'{'",
            TokenKind::RightBrace => "'}'",
            TokenKind::Slash => "'/'",
            TokenKind::Comma => "','",
            TokenKind::Semicolon => "';'",
            TokenKind::Colon => "':'",
            TokenKind::ColonColon => "::",
            TokenKind::Identifier => "identifier",
            TokenKind::String => "string",
            TokenKind::PublicKey => "public_key",
            TokenKind::Url => "'url'",
            TokenKind::Import => "'import'",
            TokenKind::Brigadier => "'brigadier'",
            TokenKind::Major => "'major'",
            TokenKind::Eof => "<EOF>",
            TokenKind::UnterminatedString => "<Unterminated String>",
            TokenKind::Unknown => "<Unknown>",
        })
    }
}
