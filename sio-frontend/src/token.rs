use alloc::fmt::Display;
use alloc::string::String;

#[derive(PartialEq, Debug, Clone)]
pub enum Token {
    // Single-character tokens.
    LeftParen,
    RightParen,
    LeftBrace,
    RightBrace,
    LeftBracket,
    RightBracket,
    Comma,
    Dot,
    Minus,
    Plus,
    Semicolon,
    Slash,
    Star,

    // One or two character tokens.
    Bang,
    BangEqual,
    Colon,
    ColonColon,
    Equal,
    EqualEqual,
    Greater,
    GreaterEqual,
    Less,
    LessEqual,
    Arrow,

    // Literals.
    Identifier(String),
    String(String),
    PublicKey(String),
    Number(f64),
    True,
    False,

    // Keywords.
    And,
    Nil,
    Or,
    General,
    Brigadier,
    Major,
    Corporal,
    Majors,
    Corporals,
    Pub,
    Let,
    Thread,
    Url,
    Use,
    If,
    Else,
    Print,
    Fun,

    // Other.
    Eof,
    UnterminatedString,
    Unknown(char),
}

#[derive(Copy, Clone, Debug, PartialEq)]
pub enum TokenKind {
    // Single-character tokens.
    LeftParen,
    RightParen,
    LeftBrace,
    RightBrace,
    LeftBracket,
    RightBracket,
    Comma,
    Dot,
    Minus,
    Plus,
    Semicolon,
    Slash,
    Star,

    // One or two character tokens.
    Bang,
    BangEqual,
    Colon,
    ColonColon,
    Equal,
    EqualEqual,
    Greater,
    GreaterEqual,
    Less,
    LessEqual,
    Arrow,

    // Literals.
    Identifier,
    String,
    PublicKey,
    Number,
    True,
    False,

    // Keywords.
    And,
    Or,
    Nil,
    General,
    Brigadier,
    Major,
    Corporal,
    Majors,
    Corporals,
    Pub,
    Let,
    Thread,
    Use,
    Url,
    If,
    Else,
    Print,
    Fun,

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
            Token::Dot => TokenKind::Dot,
            Token::Minus => TokenKind::Minus,
            Token::Plus => TokenKind::Plus,
            Token::Star => TokenKind::Star,
            Token::Bang => TokenKind::Bang,
            Token::BangEqual => TokenKind::BangEqual,
            Token::And => TokenKind::And,
            Token::Nil => TokenKind::Nil,
            Token::Or => TokenKind::Or,
            Token::Greater => TokenKind::Greater,
            Token::GreaterEqual => TokenKind::GreaterEqual,
            Token::Less => TokenKind::Less,
            Token::LessEqual => TokenKind::LessEqual,
            Token::Arrow => TokenKind::Arrow,
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
            Token::General => TokenKind::General,
            Token::Brigadier => TokenKind::Brigadier,
            Token::Major => TokenKind::Major,
            Token::Corporal=> TokenKind::Corporal,
            Token::Majors=> TokenKind::Majors,
            Token::Corporals=> TokenKind::Corporals,
            Token::Pub => TokenKind::Pub,
            Token::Let => TokenKind::Let,
            Token::Thread => TokenKind::Thread,
            Token::Use => TokenKind::Use,
            Token::If => TokenKind::If,
            Token::Else => TokenKind::Else,
            Token::Print => TokenKind::Print,
            Token::Fun => TokenKind::Fun,
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
            TokenKind::Dot => "'.'",
            TokenKind::Minus => "'-'",
            TokenKind::Plus => "'+'",
            TokenKind::Star => "'*'",
            TokenKind::Bang => "'!'",
            TokenKind::BangEqual => "'!='",
            TokenKind::EqualEqual => "'=='",
            TokenKind::And => "'and'",
            TokenKind::Nil => "nil",
            TokenKind::Or => "'or'",
            TokenKind::Greater => "'>'",
            TokenKind::GreaterEqual => "'>='",
            TokenKind::Less => "'<'",
            TokenKind::LessEqual => "'<='",
            TokenKind::Arrow => "'->'",
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
            TokenKind::Use => "'use'",
            TokenKind::General => "'general'",
            TokenKind::Brigadier => "'brigadier'",
            TokenKind::Major => "'major'",
            TokenKind::Corporal=> "'corporal'",
            TokenKind::Majors=> "'majors'",
            TokenKind::Corporals => "'corporals'",
            TokenKind::Pub => "'pub'",
            TokenKind::Let => "'let'",
            TokenKind::Thread => "'thread'",
            TokenKind::If => "'if'",
            TokenKind::Else => "'else'",
            TokenKind::Print => "'print'",
            TokenKind::Fun => "'fn'",
            TokenKind::Eof => "<EOF>",
            TokenKind::UnterminatedString => "<Unterminated String>",
            TokenKind::Unknown => "<Unknown>",
        })
    }
}
