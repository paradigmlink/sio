use super::token::Token;
use crate::brigadier::position::*;
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
            ' ' => None,
            '/' => {
                if self.it.consume_if(|ch| ch == '/') {
                    self.it.consume_while(|ch| ch != '\n');
                    None
                } else {
                    Some(Token::Slash)
                }
            }
            '\n' => None,
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
            ',' => Some(Token::Comma),
            '[' => Some(Token::LeftBracket),
            ']' => Some(Token::RightBracket),
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

    //TODO Static the keywords
    fn keyword(&self, identifier: &str) -> Option<Token> {
        use hashbrown::HashMap;
        let mut keywords: HashMap<&str, Token> = HashMap::new();
        keywords.insert("import", Token::Import);

        match keywords.get(identifier) {
            None => None,
            Some(token) => Some(token.clone()),
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
    }
}

/*

[
  "sio_major_1",
  "sio_major_2",
  "sio_major_3",
]
*/
