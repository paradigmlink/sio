use alloc::fmt::Display;
use alloc::string::String;

#[derive(PartialEq, Debug, Clone)]
pub enum Token {
    LeftBracket,
    RightBracket,
    LeftBrace,
    RightBrace,
    LeftParen,
    RightParen,
    Comma,
    Slash,
    Url,
    Semicolon,
    Colon,
    ColonColon,
    Equal,
    EqualEqual,

    // Literals.
    Identifier(String),
    String(String),
    PublicKey(String),
    Number(f64),
    True,
    False,

    // Keywords.
    Brigadier,
    Major,
    Corporal,
    Majors,
    Corporals,
    PublicFun,
    Let,
    Thread,
    Import,
    If,
    Else,

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
    LeftParen,
    RightParen,
    Comma,
    Slash,
    Url,
    Semicolon,
    Colon,
    ColonColon,
    Equal,
    EqualEqual,

    // Literals.
    Identifier,
    String,
    PublicKey,
    Number,
    True,
    False,

    // Keywords.
    Brigadier,
    Major,
    Corporal,
    Majors,
    Corporals,
    PublicFun,
    Let,
    Thread,
    Import,
    If,
    Else,

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
            Token::LeftParen => TokenKind::LeftParen,
            Token::RightParen => TokenKind::RightParen,
            Token::Comma => TokenKind::Comma,
            Token::Slash => TokenKind::Slash,
            Token::Identifier(_) => TokenKind::Identifier,
            Token::String(_) => TokenKind::String,
            Token::PublicKey(_) => TokenKind::PublicKey,
            Token::Number(_) => TokenKind::Number,
            Token::True => TokenKind::True,
            Token::False => TokenKind::False,
            Token::Url => TokenKind::Url,
            Token::Semicolon => TokenKind::Semicolon,
            Token::Colon => TokenKind::Colon,
            Token::ColonColon => TokenKind::ColonColon,
            Token::Equal => TokenKind::Equal,
            Token::EqualEqual => TokenKind::EqualEqual,
            Token::Brigadier => TokenKind::Brigadier,
            Token::Major => TokenKind::Major,
            Token::Corporal=> TokenKind::Corporal,
            Token::Majors=> TokenKind::Majors,
            Token::Corporals=> TokenKind::Corporals,
            Token::PublicFun => TokenKind::PublicFun,
            Token::Let => TokenKind::Let,
            Token::Thread => TokenKind::Thread,
            Token::Import => TokenKind::Import,
            Token::If => TokenKind::If,
            Token::Else => TokenKind::Else,
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
            TokenKind::LeftParen => "'('",
            TokenKind::RightParen => "')'",
            TokenKind::Slash => "'/'",
            TokenKind::Comma => "','",
            TokenKind::Semicolon => "';'",
            TokenKind::Colon => "':'",
            TokenKind::ColonColon => "'::'",
            TokenKind::Equal => "'='",
            TokenKind::EqualEqual => "'=='",
            TokenKind::Identifier => "identifier",
            TokenKind::String => "string",
            TokenKind::PublicKey => "public_key",
            TokenKind::Number => "number",
            TokenKind::True => "true",
            TokenKind::False => "false",
            TokenKind::Url => "'url'",
            TokenKind::Import => "'import'",
            TokenKind::Brigadier => "brigadier",
            TokenKind::Major => "major",
            TokenKind::Corporal=> "corporal",
            TokenKind::Majors=> "majors",
            TokenKind::Corporals => "corporals",
            TokenKind::PublicFun => "pub",
            TokenKind::Let => "let",
            TokenKind::Thread => "thread",
            TokenKind::If => "if",
            TokenKind::Else => "else",
            TokenKind::Eof => "<EOF>",
            TokenKind::UnterminatedString => "<Unterminated String>",
            TokenKind::Unknown => "<Unknown>",
        })
    }
}
