use {
    super::*,
    internment::Intern,
    std::ops::Deref,
};

#[derive(Copy, Clone, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub struct Ident(Intern<String>);

impl fmt::Display for Ident {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result { write!(f, "{}", self.0) }
}

impl fmt::Debug for Ident {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result { write!(f, "`{}`", self.0) }
}

impl Ident {
    pub fn new<S: ToString>(s: S) -> Self { Self(Intern::new(s.to_string())) }
    pub fn as_ref(self) -> &'static String { self.0.as_ref() }
}

impl Deref for Ident {
    type Target = String;

    fn deref(&self) -> &Self::Target { &self.0 }
}

#[derive(Copy, Clone, PartialEq)]
pub enum Literal {
    Bool(bool),
    Char(char),
    Str(Intern<String>),
}

impl fmt::Debug for Literal {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Self::Bool(x) => write!(f, "`{}`", x),
            Self::Char(c) => write!(f, "`{}`", c),
            Self::Str(s) => write!(f, "`\"{}\"`", s),
        }
    }
}
