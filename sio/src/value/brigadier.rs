use werbolg_core::{ConstrId, ValueFun};
use werbolg_exec::{ExecutionError, Valuable, ValueKind};

pub type ValueInt = u64;

#[derive(Clone, Debug)]
pub enum BrigadierValue {
    Unit,
    Unbound,
    Bool(bool),
    Integral(ValueInt),
    Fun(ValueFun),
}

impl BrigadierValue {
    fn desc(&self) -> ValueKind {
        match self {
            BrigadierValue::Unit => UNIT_KIND,
            BrigadierValue::Unbound => UNBOUND_KIND,
            BrigadierValue::Bool(_) => BOOL_KIND,
            BrigadierValue::Integral(_) => INT_KIND,
            BrigadierValue::Fun(_) => FUN_KIND,
        }
    }
}

pub const UNIT_KIND: ValueKind = "    unit";
pub const UNBOUND_KIND: ValueKind = " unbound";
pub const BOOL_KIND: ValueKind = "    bool";
pub const INT_KIND: ValueKind = "     int";
pub const FUN_KIND: ValueKind = "     fun";

impl Valuable for BrigadierValue {
    fn descriptor(&self) -> werbolg_exec::ValueKind {
        self.desc()
    }

    fn conditional(&self) -> Option<bool> {
        match self {
            BrigadierValue::Bool(b) => Some(*b),
            _ => None,
        }
    }

    fn fun(&self) -> Option<ValueFun> {
        match self {
            Self::Fun(valuefun) => Some(*valuefun),
            _ => None,
        }
    }

    fn structure(&self) -> Option<(ConstrId, &[Self])> {
        None
    }

    fn index(&self, _index: usize) -> Option<&Self> {
        None
    }

    fn make_fun(fun: ValueFun) -> Self {
        BrigadierValue::Fun(fun)
    }

    fn make_dummy() -> Self {
        BrigadierValue::Unit
    }
}

impl BrigadierValue {
    pub fn int(&self) -> Result<ValueInt, ExecutionError> {
        match self {
            BrigadierValue::Integral(o) => Ok(*o),
            _ => Err(ExecutionError::ValueKindUnexpected {
                value_expected: INT_KIND,
                value_got: self.descriptor(),
            }),
        }
    }
}
