#[derive(Debug, Copy, Clone, PartialEq, PartialOrd, Eq, Ord, Default)]
pub struct BytePos(pub u32);

impl BytePos {
    pub fn shift(self, ch: char) -> Self {
        BytePos(self.0 + ch.len_utf8() as u32)
    }
}

#[derive(Debug, Clone, Copy, PartialEq, PartialOrd)]
pub struct Span {
    pub start: BytePos,
    pub end: BytePos,
}
