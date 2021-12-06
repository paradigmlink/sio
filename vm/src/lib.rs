mod parse;
mod eval;
pub use crate::{
    parse::parser,
    eval::eval,
};
pub use chumsky::{Parser};

