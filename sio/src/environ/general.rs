use crate::value::general::{self, GeneralValue as Value, ValueInt};
use crate::allocator::GeneralAllocator as Alloc;
use werbolg_compile::{CompilationError, Environment};
use werbolg_core::{AbsPath, Ident, Literal, Namespace, Span};
use werbolg_exec::{ExecutionError, NIFCall, WAllocator, NIF, ExecutionMachine};
use crate::{GeneralExecutionMachine, GeneralNIF};
use alloc::string::ToString;

fn nif_unbound(em: &mut GeneralExecutionMachine<'_, '_>) -> Result<Value, ExecutionError> {
    let (i_dont_know, args) = em.stack.get_call_and_args(em.current_arity);
    if args.is_empty() {
        Ok(Value::Unbound)
    } else {
        Err(ExecutionError::UserPanic {
            message: "`nil' function does not need any arguments".to_string(),
        })
    }
}
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
pub enum GeneralLiteral {
    Bool(bool),
    Int(ValueInt),
}

pub fn general_literal_to_value(lit: &GeneralLiteral) -> Value {
    match lit {
        GeneralLiteral::Bool(b) => Value::Bool(*b),
        GeneralLiteral::Int(n) => Value::Integral(*n),
    }
}

// only support bool and number from the werbolg core literal
pub fn general_literal_mapper(span: Span, lit: Literal) -> Result<GeneralLiteral, CompilationError> {
    match lit {
        Literal::Bool(b) => {
            let b = b.as_ref() == "true";
            Ok(GeneralLiteral::Bool(b))
        }
        Literal::Number(s) => {
            let Ok(v) = ValueInt::from_str_radix(s.as_ref(), 10) else {
                todo!()
            };
            Ok(GeneralLiteral::Int(v))
        }
        Literal::String(_) => Err(CompilationError::LiteralNotSupported(span, lit)),
        Literal::Decimal(_) => Err(CompilationError::LiteralNotSupported(span, lit)),
        Literal::Bytes(_) => Err(CompilationError::LiteralNotSupported(span, lit)),
    }
}

pub fn create_general_env<'m, 'e>(
) -> Environment<GeneralNIF<'m, 'e>, Value> {
    macro_rules! add_raw_nif {
        ($env:ident, $i:literal, $e:expr) => {
            let nif = NIF {
                name: $i,
                call: NIFCall::Raw($e),
            };
            let path = AbsPath::new(&Namespace::root(), &Ident::from($i));
            $env.add_nif(&path, nif);
        };
    }
    macro_rules! add_pure_nif {
        ($env:ident, $i:literal, $e:expr) => {
            let nif = NIF {
                name: $i,
                call: NIFCall::Pure($e),
            };
            let path = AbsPath::new(&Namespace::root(), &Ident::from($i));
            $env.add_nif(&path, nif);
        };
    }

    let mut env = Environment::new();
    add_raw_nif!(env, "unbound", nif_unbound);
    add_pure_nif!(env, "+", nif_plus);
    add_pure_nif!(env, "-", nif_sub);
    add_pure_nif!(env, "*", nif_mul);
    add_pure_nif!(env, "==", nif_eq);
    add_pure_nif!(env, "<=", nif_le);
    add_pure_nif!(env, "neg", nif_neg);

    env
}
