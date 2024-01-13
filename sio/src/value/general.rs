use werbolg_core::{ConstrId, ValueFun};
use werbolg_exec::{ExecutionError, Valuable, ValueKind};

pub type ValueInt = u64;

#[derive(Clone, Debug)]
pub enum GeneralValue {
    Unit,
    Unbound,
    Bool(bool),
    Integral(ValueInt),
    Fun(ValueFun),
}

impl GeneralValue {
    fn desc(&self) -> ValueKind {
        match self {
            GeneralValue::Unit => UNIT_KIND,
            GeneralValue::Unbound => UNBOUND_KIND,
            GeneralValue::Bool(_) => BOOL_KIND,
            GeneralValue::Integral(_) => INT_KIND,
            GeneralValue::Fun(_) => FUN_KIND,
        }
    }
}

pub const UNIT_KIND: ValueKind = "    unit";
pub const UNBOUND_KIND: ValueKind = " unbound";
pub const BOOL_KIND: ValueKind = "    bool";
pub const INT_KIND: ValueKind = "     int";
pub const FUN_KIND: ValueKind = "     fun";

impl Valuable for GeneralValue {
    fn descriptor(&self) -> werbolg_exec::ValueKind {
        self.desc()
    }

    fn conditional(&self) -> Option<bool> {
        match self {
            GeneralValue::Bool(b) => Some(*b),
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
        GeneralValue::Fun(fun)
    }

    fn make_dummy() -> Self {
        GeneralValue::Unit
    }
}

impl GeneralValue {
    pub fn int(&self) -> Result<ValueInt, ExecutionError> {
        match self {
            GeneralValue::Integral(o) => Ok(*o),
            _ => Err(ExecutionError::ValueKindUnexpected {
                value_expected: INT_KIND,
                value_got: self.descriptor(),
            }),
        }
    }
}
