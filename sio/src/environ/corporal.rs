use crate::value::corporal::{self, CorporalValue as Value, ValueInt};
use crate::allocator::CorporalAllocator as Alloc;
use werbolg_compile::{CompilationError, Environment, CallArity};
use werbolg_core::{AbsPath, Ident, Literal, Namespace, Span};
use werbolg_exec::{ExecutionError, NIFCall, WAllocator, NIF};

fn nif_plus<A: WAllocator>(_: &A, args: &[Value]) -> Result<Value, ExecutionError> {
    let n1 = args[0].int()?;
    let n2 = args[1].int()?;

    let ret = Value::Integral(n1 + n2);

    Ok(ret)
}

fn nif_sub<A: WAllocator>(_: &A, args: &[Value]) -> Result<Value, ExecutionError> {
    let n1 = args[0].int()?;
    let n2 = args[1].int()?;

    let ret = Value::Integral(n1 - n2);

    Ok(ret)
}

fn nif_mul<A: WAllocator>(_: &A, args: &[Value]) -> Result<Value, ExecutionError> {
    let n1 = args[0].int()?;
    let n2 = args[1].int()?;

    let ret = Value::Integral(n1 * n2);

    Ok(ret)
}

fn nif_neg<A: WAllocator>(_: &A, args: &[Value]) -> Result<Value, ExecutionError> {
    let n1 = args[0].int()?;

    let ret = !n1;

    Ok(Value::Integral(ret))
}

fn nif_eq<A: WAllocator>(_: &A, args: &[Value]) -> Result<Value, ExecutionError> {
    let n1 = args[0].int()?;
    let n2 = args[1].int()?;

    let ret = n1 == n2;

    Ok(Value::Bool(ret))
}

fn nif_le<A: WAllocator>(_: &A, args: &[Value]) -> Result<Value, ExecutionError> {
    let n1 = args[0].int()?;
    let n2 = args[1].int()?;

    let ret = n1 <= n2;

    Ok(Value::Bool(ret))
}

#[derive(Clone, PartialEq, Eq, Hash)]
pub enum CorporalLiteral {
    Bool(bool),
    Int(ValueInt),
}

pub fn literal_to_value(lit: &CorporalLiteral) -> Value {
    match lit {
        CorporalLiteral::Bool(b) => Value::Bool(*b),
        CorporalLiteral::Int(n) => Value::Integral(*n),
    }
}

// only support bool and number from the werbolg core literal
pub fn literal_mapper(span: Span, lit: Literal) -> Result<CorporalLiteral, CompilationError> {
    match lit {
        Literal::Bool(b) => {
            let b = b.as_ref() == "true";
            Ok(CorporalLiteral::Bool(b))
        }
        Literal::Number(s) => {
            let Ok(v) = ValueInt::from_str_radix(s.as_ref(), 10) else {
                todo!()
            };
            Ok(CorporalLiteral::Int(v))
        }
        Literal::String(_) => Err(CompilationError::LiteralNotSupported(span, lit)),
        Literal::Decimal(_) => Err(CompilationError::LiteralNotSupported(span, lit)),
        Literal::Bytes(_) => Err(CompilationError::LiteralNotSupported(span, lit)),
    }
}

pub fn create_env<'m, 'e>(
) -> Environment<NIF<'m, 'e, Alloc, CorporalLiteral, (), Value>, Value> {
    macro_rules! add_raw_nif {
        ($env:ident, $i:literal, $arity:literal, $e:expr) => {
            let nif = NIFCall::Raw($e).info($i, CallArity::try_from($arity as usize).unwrap());
            let path = AbsPath::new(&Namespace::root(), &Ident::from($i));
            $env.add_nif(&path, nif);
        };
    }
    macro_rules! add_pure_nif {
        ($env:ident, $i:literal, $arity:literal, $e:expr) => {
            let nif = NIFCall::Pure($e).info($i, CallArity::try_from($arity as usize).unwrap());
            let path = AbsPath::new(&Namespace::root(), &Ident::from($i));
            $env.add_nif(&path, nif);
        };
    }
    let mut env = Environment::new();
    add_pure_nif!(env, "+", 2, nif_plus);
    add_pure_nif!(env, "-", 2, nif_sub);
    add_pure_nif!(env, "*", 2, nif_mul);
    add_pure_nif!(env, "==", 2, nif_eq);
    add_pure_nif!(env, "<=", 2, nif_le);
    add_pure_nif!(env, "neg", 1, nif_neg);

    env
}
