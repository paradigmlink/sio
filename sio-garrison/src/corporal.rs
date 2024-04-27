use sio::{
    CorporalExecutionMachine, CorporalEnvironment, CorporalAllocator, CorporalLiteral, CorporalState, CorporalValue, corporal_literal_mapper, corporal_literal_to_value
};
use werbolg_core::{AbsPath, Ident, Namespace, ir::Module};
use werbolg_exec::{ ExecutionMachine, ExecutionEnviron, ExecutionParams, WerRefCount};
use werbolg_compile::{compile};
use werbolg_lang_common::{Report, ReportKind, Source};
use alloc::{ 
    format, vec, vec::Vec, boxed::Box, string::String};
use core::error::Error;
use crate::{
    //SioParams, 
    report_print, run_frontend};


fn compile_corporal(
    //params: SioParams,
    env: &mut CorporalEnvironment,
    source: Source,
    module: Module,
) -> Result<werbolg_compile::CompilationUnit<CorporalLiteral>, Box<dyn Error>> {
    //let (source, module) = run_frontend(src, path).unwrap();
    let module_ns = Namespace::root().append(Ident::from("main"));
    let modules = vec![(module_ns.clone(), module)];
    let compilation_params = werbolg_compile::CompilationParams {
        literal_mapper: corporal_literal_mapper,
        sequence_constructor: None,
    };
    let cu = match compile(&compilation_params, modules, env) {
        Err(e) => {
            let report = Report::new(ReportKind::Error, format!("Compilation Error: {:?}", e))
                .lines_before(1)
                .lines_after(1)
                .highlight(e.span().unwrap(), format!("compilation error here"));
            report_print(&source, report)?;
            return Err(format!("compilation error {:?}", e).into());
        }
        Ok(m) => m,
    };
    //if params.dump_instr {
    //    let mut out = String::new();
    //    code_dump(&mut out, &cu.code, &cu.funs).expect("writing to string work");
        //println!("{}", out);
    //}
    Ok(cu)
}

pub fn build_corporal_machine (
    ee: ExecutionEnviron<CorporalAllocator, CorporalLiteral, CorporalState, CorporalValue>,
    cu: werbolg_compile::CompilationUnit<CorporalLiteral>,
) -> Result<CorporalExecutionMachine, Box<dyn Error>> {
    let module_ns = Namespace::root().append(Ident::from("main"));
    let entry_point = cu
        .funs_tbl
        .get(&AbsPath::new(&module_ns, &Ident::from("main")))
        .expect("existing function as entry point");
    let execution_params = ExecutionParams {
        literal_to_value: corporal_literal_to_value,
    };
    let state = CorporalState {};
    let allocator = CorporalAllocator {};
    let mut em = ExecutionMachine::new(
        WerRefCount::new(cu),
        WerRefCount::new(ee),
        execution_params, allocator, state);
    werbolg_exec::initialize(&mut em, entry_point, &[]).unwrap();
    Ok(em)
}

pub struct Corporal {
    threads: Vec<CorporalExecutionMachine>,
}

impl Corporal {
    pub fn new(
        src: String,
        path: String,
        //params: SioParams,
        mut env: CorporalEnvironment,
    ) -> Result<Self, Box<dyn Error>> {
        let (source, module) = run_frontend(src, path)?;
        let cu = compile_corporal(/*params, */&mut env, source, module)?;
        let ee = werbolg_exec::ExecutionEnviron::from_compile_environment(env.finalize());
        let em = build_corporal_machine(ee, cu)?;
        Ok(Self { threads: vec![em] })
    }
    pub fn march(&mut self) -> Result<Option<CorporalValue>, Box<dyn Error>> {
        for thread in &mut self.threads {
            match werbolg_exec::step(thread).unwrap() {
                None => {},
                Some(v) => {
                    println!("thread: {:?}", v);
                    break;
                },
            }
        }
        Ok(None)
    }
}


#[cfg(test)]
mod corporal_tests {
    //use alloc::vec::Vec;
    //use alloc::vec;
    use alloc::string::ToString;
    use sio::create_corporal_env;
    use super::*;
    static src: &str =
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
        }";
    #[test]
    fn basic_dataflow() {
        let env = create_corporal_env();
        let mut corporal = Corporal::new(src.to_string(), "/".to_string(), env).expect("Corporal failure reason:");
        corporal.march();
        assert_eq!(4, 4);
    }
}
