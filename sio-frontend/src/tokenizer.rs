use super::token::Token;
use crate::position::*;
use core::iter::Peekable;
use alloc::str;
use alloc::string::String;
use alloc::str::Chars;
use alloc::vec::Vec;

struct Scanner<'a> {
    current_position: BytePos,
    it: Peekable<Chars<'a>>,
}

impl<'a> Scanner<'a> {
    fn new(buf: &str) -> Scanner {
        Scanner {
            current_position: BytePos::default(),
            it: buf.chars().peekable(),
        }
    }

    fn next(&mut self) -> Option<char> {
        let next = self.it.next();
        if let Some(c) = next {
            self.current_position = self.current_position.shift(c);
        }
        next
    }

    fn peek(&mut self) -> Option<&char> {
        self.it.peek()
    }

    // Consume next char if it matches
    fn consume_if<F>(&mut self, x: F) -> bool
    where
        F: Fn(char) -> bool,
    {
        if let Some(&ch) = self.peek() {
            if x(ch) {
                self.next().unwrap();
                true
            } else {
                false
            }
        } else {
            false
        }
    }

    // Consume next char if the next one after matches (so .3 eats . if 3 is numeric, for example)
    fn consume_if_next<F>(&mut self, x: F) -> bool
    where
        F: Fn(char) -> bool,
    {
        let mut it = self.it.clone();
        match it.next() {
            None => return false,
            _ => (),
        }

        if let Some(&ch) = it.peek() {
            if x(ch) {
                self.next().unwrap();
                true
            } else {
                false
            }
        } else {
            false
        }
    }

    fn consume_while<F>(&mut self, x: F) -> Vec<char>
    where
        F: Fn(char) -> bool,
    {
        let mut chars: Vec<char> = Vec::new();
        while let Some(&ch) = self.peek() {
            if x(ch) {
                self.next().unwrap();
                chars.push(ch);
            } else {
                break;
            }
        }
        chars
    }
}

struct Lexer<'a> {
    it: Scanner<'a>,
}

impl<'a> Lexer<'a> {
    fn new(buf: &str) -> Lexer {
        Lexer {
            it: Scanner::new(buf),
        }
    }

    fn match_token(&mut self, ch: char) -> Option<Token> {
        match ch {
            ':' => Some(self.either(':', Token::ColonColon, Token::Colon)),
            '=' => Some(self.either('=', Token::EqualEqual, Token::Equal)),
            ' ' => None,
            '\n' => None,
            '/' => self.comment_or_slash(),
            '\t' => None,
            '\r' => None,
            '"' => {
                let string: String = self.it.consume_while(|ch| ch != '"').into_iter().collect();
                // Skip last "
                match self.it.next() {
                    None => Some(Token::UnterminatedString),
                    _ => Some(Token::String(string)),
                }
            }
            x if x.is_numeric() => self.number(x),
            x if x.is_ascii_alphabetic() || x == '_' => self.identifier(x),
            ',' => Some(Token::Comma),
            '[' => Some(Token::LeftBracket),
            ']' => Some(Token::RightBracket),
            '{' => Some(Token::LeftBrace),
            '}' => Some(Token::RightBrace),
            '(' => Some(Token::LeftParen),
            ')' => Some(Token::RightParen),
            ';' => Some(Token::Semicolon),
            c => Some(Token::Unknown(c)),
        }
    }

    fn either(&mut self, to_match: char, matched: Token, unmatched: Token) -> Token {
        if self.it.consume_if(|ch| ch == to_match) {
            matched
        } else {
            unmatched
        }
    }

    fn comment_or_slash(&mut self) -> Option<Token> {
        if self.it.consume_if(|ch| ch == '/') {
            self.it.consume_while(|ch| ch != '\n');
            None
        } else  {
            Some(Token::Slash)
        }
    }

    fn number(&mut self, x: char) -> Option<Token> {
        let mut number = String::new();
        number.push(x);
        let num: String = self
            .it
            .consume_while(|a| a.is_numeric())
            .into_iter()
            .collect();
        number.push_str(num.as_str());
        if self.it.peek() == Some(&'.') && self.it.consume_if_next(|ch| ch.is_numeric()) {
            let num2: String = self
                .it
                .consume_while(|a| a.is_numeric())
                .into_iter()
                .collect();
            number.push('.');
            number.push_str(num2.as_str());
        }
        Some(Token::Number(number.parse::<f64>().unwrap()))
    }

    //TODO Static the keywords
    fn keyword(&self, identifier: &str) -> Option<Token> {
        use hashbrown::HashMap;
        let mut keywords: HashMap<&str, Token> = HashMap::new();
        keywords.insert("import", Token::Import);
        keywords.insert("url", Token::Url);
        keywords.insert("brigadier", Token::Brigadier);
        keywords.insert("major", Token::Major);
        keywords.insert("corporal", Token::Corporal);
        keywords.insert("majors", Token::Majors);
        keywords.insert("corporals", Token::Corporals);
        keywords.insert("pub", Token::PublicFun);
        keywords.insert("let", Token::Let);
        keywords.insert("thread", Token::Thread);
        keywords.insert("if", Token::If);
        keywords.insert("else", Token::Else);
        keywords.insert("true", Token::True);
        keywords.insert("false", Token::False);
        match keywords.get(identifier) {
            None => None,
            Some(token) => Some(token.clone()),
        }
    }

    fn identifier(&mut self, x: char) -> Option<Token> {
        let mut identifier = String::new();
        identifier.push(x);
        let rest: String = self
            .it
            .consume_while(|a| a.is_ascii_alphanumeric() || a == '_')
            .into_iter()
            .collect();
        identifier.push_str(rest.as_str());
        if identifier.starts_with("spub1") {
            if identifier.len() == 69 {
                if !identifier.contains('_') {
                    return Some(Token::PublicKey(identifier));
                }
            }
        }
        match self.keyword(&identifier) {
            None => Some(Token::Identifier(identifier)),
            Some(token) => Some(token),
        }
    }
    fn tokenize_with_context(&mut self) -> Vec<WithSpan<Token>> {
        let mut tokens: Vec<WithSpan<Token>> = Vec::new();
        loop {
            let initial_position = self.it.current_position;
            let ch = match self.it.next() {
                None => break,
                Some(c) => c,
            };
            if let Some(token) = self.match_token(ch) {
                tokens.push(WithSpan::new(
                    token,
                    Span {
                        start: initial_position,
                        end: self.it.current_position,
                    },
                ));
            }
        }
        tokens
    }
}

pub fn tokenize_with_context(buf: &str) -> Vec<WithSpan<Token>> {
    let mut t = Lexer::new(buf);
    t.tokenize_with_context()
}

#[cfg(test)]
mod tests {
    use super::Token;
    use alloc::vec::Vec;
    use alloc::vec;
    use crate::alloc::string::ToString;
    fn tokenize(buf: &str) -> Vec<Token> {
        use super::tokenize_with_context;
        tokenize_with_context(buf)
            .iter()
            .map(|tc| tc.value.clone())
            .collect()
    }

    #[test]
    fn test_errors() {
        assert_eq!(tokenize("\"test"), vec![Token::UnterminatedString]);
        assert_eq!(tokenize("spub1_9f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03aba"),
            vec![Token::Identifier("spub1_9f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03aba".to_string())]);
    }

    #[test]
    fn test() {
        assert_eq!(tokenize(""), vec![]);
        assert_eq!(tokenize("[\"sio_major\"]"), vec![Token::LeftBracket, Token::String("sio_major".to_string()), Token::RightBracket]);
        assert_eq!(tokenize("[\"sio_major_1\", \"sio_major_2\"]"),
            vec![Token::LeftBracket, Token::String("sio_major_1".to_string()), Token::Comma, Token::String("sio_major_2".to_string()), Token::RightBracket]);
        assert_eq!(tokenize("[\"1\", \"2\", \"3\"]"),
            vec![Token::LeftBracket,
                  Token::String("1".to_string()), Token::Comma,
                  Token::String("2".to_string()), Token::Comma,
                  Token::String("3".to_string()),
                  Token::RightBracket]);
        assert_eq!(tokenize("//test"), vec![]);
        assert_eq!(
            tokenize("\"test\""),
            vec![Token::String("test".to_string())]
        );
        assert_eq!(tokenize("["), vec![Token::LeftBracket]);
        assert_eq!(tokenize("]"), vec![Token::RightBracket]);
        assert_eq!(tokenize("spub179f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03aba"),
            vec![Token::PublicKey("spub179f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03aba".to_string())]);
        assert_eq!(tokenize("url pk0 : spub179f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03aba;"),
            vec![
                Token::Url,
                Token::Identifier("pk0".to_string()),
                Token::Colon,
                Token::PublicKey("spub179f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03aba".to_string()),
                Token::Semicolon
            ]
        );
        assert_eq!(tokenize("url top   : \"top\"::\"level\";"),
            vec![
                Token::Url,
                Token::Identifier("top".to_string()),
                Token::Colon,
                Token::String("top".to_string()),
                Token::ColonColon,
                Token::String("level".to_string()),
                Token::Semicolon,
            ]
        );
        assert_eq!(tokenize(
            "brigadier brig::Brigadier {
                majors {
                    app1::Major1,
                    spub179f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03aba::\"app3\"::Major3,
                    //app1::Commented,
                    app2,
                }
            }"
        ), vec![
                Token::Brigadier,
                Token::Identifier("brig".to_string()),
                Token::ColonColon,
                Token::Identifier("Brigadier".to_string()),
                Token::LeftBrace,
                Token::Majors,
                Token::LeftBrace,
                Token::Identifier("app1".to_string()),
                Token::ColonColon,
                Token::Identifier("Major1".to_string()),
                Token::Comma,
                Token::PublicKey("spub179f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03aba".to_string()),
                Token::ColonColon,
                Token::String("app3".to_string()),
                Token::ColonColon,
                Token::Identifier("Major3".to_string()),
                Token::Comma,
                Token::Identifier("app2".to_string()),
                Token::Comma,
                Token::RightBrace,
                Token::RightBrace,
            ]
        );
        assert_eq!(tokenize(
            "major maj::Major {
                corporals {
                    app1::Corporal1,
                    spub179f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03aba::\"app3\"::Corporal2,
                    //app1::Commented,
                    app3,
                }
            }"
        ), vec![
                Token::Major,
                Token::Identifier("maj".to_string()),
                Token::ColonColon,
                Token::Identifier("Major".to_string()),
                Token::LeftBrace,
                Token::Corporals,
                Token::LeftBrace,
                Token::Identifier("app1".to_string()),
                Token::ColonColon,
                Token::Identifier("Corporal1".to_string()),
                Token::Comma,
                Token::PublicKey("spub179f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03aba".to_string()),
                Token::ColonColon,
                Token::String("app3".to_string()),
                Token::ColonColon,
                Token::Identifier("Corporal2".to_string()),
                Token::Comma,
                Token::Identifier("app3".to_string()),
                Token::Comma,
                Token::RightBrace,
                Token::RightBrace,
            ]
        );

        assert_eq!(tokenize(
            "corporal corp::Corporal {
                pub main :: () {
                    let x;
                    thread {
                      x = 0;
                    }
                    if x == 0 {
                      true
                    } else {
                      false
                    }
                }
            }"
        ), vec![
                Token::Corporal,
                Token::Identifier("corp".to_string()),
                Token::ColonColon,
                Token::Identifier("Corporal".to_string()),
                Token::LeftBrace,
                Token::PublicFun,
                Token::Identifier("main".to_string()),
                Token::ColonColon,
                Token::LeftParen,
                Token::RightParen,
                Token::LeftBrace,
                Token::Let,
                Token::Identifier("x".to_string()),
                Token::Semicolon,
                Token::Thread,
                Token::LeftBrace,
                Token::Identifier("x".to_string()),
                Token::Equal,
                Token::Number(0.0),
                Token::Semicolon,
                Token::RightBrace,
                Token::If,
                Token::Identifier("x".to_string()),
                Token::EqualEqual,
                Token::Number(0.0),
                Token::LeftBrace,
                Token::True,
                Token::RightBrace,
                Token::Else,
                Token::LeftBrace,
                Token::False,
                Token::RightBrace,
                Token::RightBrace,
                Token::RightBrace,

            ]
        );
    }
}

