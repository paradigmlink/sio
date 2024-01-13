//#![no_std]
extern crate alloc;
extern crate proc_macro;

use hashbrown::{HashMap, HashSet};
use werbolg_ir_write::module;
use werbolg_exec::{ ExecutionError, ExecutionMachine, ExecutionParams, WAllocator, ExecutionEnviron, NIFCall, NIF };
use werbolg_core::{Literal, Path, Ident, Namespace, AbsPath, id::IdF};
use werbolg_compile::{compile, CompilationError, CompilationParams, Environment, code_dump, InstructionAddress};
use sio::value::{Value};
use single_assignment_store::SingleAssignmentStore;

fn nif_plus(args: &[Value]) -> Result<Value, ExecutionError> {
    let n1 = args[0].int()?;
    let n2 = args[1].int()?;

    let ret = Value::Integral(n1 + n2);

    Ok(ret)
}

fn nif_sub(args: &[Value]) -> Result<Value, ExecutionError> {
    let n1 = args[0].int()?;
    let n2 = args[1].int()?;

    let ret = Value::Integral(n1 - n2);

    Ok(ret)
}

fn nif_mul(args: &[Value]) -> Result<Value, ExecutionError> {
    let n1 = args[0].int()?;
    let n2 = args[1].int()?;

    let ret = Value::Integral(n1 * n2);

    Ok(ret)
}

pub struct DummyAlloc;

impl WAllocator for DummyAlloc {
    type Value = Value;
}


#[derive(Clone, PartialEq, Eq, Hash)]
pub enum MyLiteral {
    Bool(bool),
    Int(u64),
}

fn literal_to_value(lit: &MyLiteral) -> Value {
    match lit {
        MyLiteral::Bool(b) => Value::Bool(*b),
        MyLiteral::Int(n) => Value::Integral(*n),
    }
}

// only support bool and number from the werbolg core literal
fn literal_mapper(lit: Literal) -> Result<MyLiteral, CompilationError> {
    match lit {
        Literal::Bool(b) => {
            let b = b.as_ref() == "true";
            Ok(MyLiteral::Bool(b))
        }
        Literal::Number(s) => {
            let Ok(v) = u64::from_str_radix(s.as_ref(), 10) else {
                todo!()
            };
            Ok(MyLiteral::Int(v))
        }
        Literal::String(_) => Err(CompilationError::LiteralNotSupported(lit)),
        Literal::Decimal(_) => Err(CompilationError::LiteralNotSupported(lit)),
        Literal::Bytes(_) => Err(CompilationError::LiteralNotSupported(lit)),
    }
}

fn module2() -> werbolg_core::Module {
    module! {
        fn main() {
            1
        }
    }
}

fn module1() -> werbolg_core::Module {
    module! {
        fn one() {
            1
        }
        fn main() {
            plus(one(), one())
        }
    }
}

fn main() -> Result<(), ()> {


    let module_ns = Namespace::root().append(Ident::from("main"));
    let module = module1();
    //println!("mod {:?}", module);
    let modules = vec![(module_ns.clone(), module)];

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
    add_pure_nif!(env, "plus", nif_plus);
    add_pure_nif!(env, "sub", nif_sub);
    add_pure_nif!(env, "mul", nif_mul);

    let compilation_params = werbolg_compile::CompilationParams { literal_mapper };
    let exec_module =
        compile(&compilation_params, modules, &mut env).expect("no compilation error");

    let ee = ExecutionEnviron::from_compile_environment(env.finalize());

    let mut out = String::new();
    code_dump(&mut out, &exec_module.code, &exec_module.funs).expect("writing to string work");
    println!("{}", out);

    let entry_point = exec_module
        .funs_tbl
        .get(&AbsPath::new(&module_ns, &Ident::from("main")))
        .expect("existing function as entry point");

    let execution_params = ExecutionParams { literal_to_value };
    let mut sss: SingleAssignmentStore<AbsPath, Value> = SingleAssignmentStore::new();
    let mut em = ExecutionMachine::new(&exec_module, &ee, execution_params, DummyAlloc, sss);

    let mut stepper = HashSet::<InstructionAddress>::new();
    stepper.insert(InstructionAddress::from_collection_len(0x04));
    /*
    stepper.insert(InstructionAddress::from_collection_len(0x13));
    stepper.insert(InstructionAddress::from_collection_len(0x14));
    stepper.insert(InstructionAddress::from_collection_len(0x24));
    */

    let ret = if !stepper.is_empty() {
        werbolg_exec::initialize(&mut em, entry_point, &[]).unwrap();
        loop {
            if stepper.contains(&em.ip) {
                let mut out = String::new();
                em.debug_state(&mut out).unwrap();
                println!("{}", out);
            }
            match werbolg_exec::step(&mut em) {
                Err(e) => break Err(e),
                Ok(None) => {}
                Ok(Some(v)) => break Ok(v),
            }
        }
    } else {
        werbolg_exec::exec(&mut em, entry_point, &[])
    };

    match ret {
        Err(e) => {
            let mut out = String::new();
            em.debug_state(&mut out).unwrap();

            println!("error: {:?} at {}", e, em.ip);
            println!("{}", out);
            return Err(());
        }
        Ok(val) => {
            println!("{:?}", val);
            Ok(())
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use alloc::vec;

    use werbolg_compile::{compile, CompilationError, CompilationParams, Environment, NamespaceResolver, code_dump};
    use werbolg_core::{Ident, Namespace};
    use werbolg_exec::{ ExecutionEnviron, ExecutionError, NIFCall, NIF };

    #[test]
    fn it_compiles() {
    }
}
