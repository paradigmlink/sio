use sio::{
    MajorExecutionMachine, MajorEnvironment, MajorAllocator, MajorLiteral, MajorState, MajorValue, major_literal_mapper, major_literal_to_value
};
use werbolg_core::{AbsPath, Ident, Namespace, ir::Module};
use werbolg_exec::{ExecutionMachine, ExecutionEnviron, ExecutionParams, WerRefCount};
use werbolg_compile::{compile};
use werbolg_lang_common::{Report, ReportKind, Source};
use alloc::{format, vec, boxed::Box, string::String};
use core::error::Error;
use crate::{ report_print, run_frontend};


fn compile_major(
    //params: SioParams,
    env: &mut MajorEnvironment,
    source: Source,
    module: Module,
) -> Result<werbolg_compile::CompilationUnit<MajorLiteral>, Box<dyn Error>> {
    //let (source, module) = run_frontend(src, path).unwrap();
    let module_ns = Namespace::root().append(Ident::from("main"));
    let modules = vec![(module_ns.clone(), module)];
    let compilation_params = werbolg_compile::CompilationParams {
        literal_mapper: major_literal_mapper,
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

pub fn build_major_machine (
    ee: ExecutionEnviron<MajorAllocator, MajorLiteral, MajorState, MajorValue>,
    cu: werbolg_compile::CompilationUnit<MajorLiteral>,
) -> Result<MajorExecutionMachine, Box<dyn Error>> {
    let module_ns = Namespace::root().append(Ident::from("main"));
    let entry_point = cu
        .funs_tbl
        .get(&AbsPath::new(&module_ns, &Ident::from("main")))
        .expect("existing function as entry point");
    let execution_params = ExecutionParams {
        literal_to_value: major_literal_to_value,
    };
    let state = MajorState {};
    let allocator = MajorAllocator {};
    let mut em = ExecutionMachine::new(
        WerRefCount::new(cu),
        WerRefCount::new(ee),
        execution_params, allocator, state);
    werbolg_exec::initialize(&mut em, entry_point, &[]).unwrap();
    Ok(em)
}

pub struct Major {
    em: MajorExecutionMachine,
}

impl Major {
    pub fn new(
        src: String,
        path: String,
        //params: SioParams,
        mut env: MajorEnvironment,
    ) -> Result<Self, Box<dyn Error>> {
        let (source, module) = run_frontend(src, path)?;
        let cu = compile_major(/*params, */ &mut env, source, module)?;
        let ee = werbolg_exec::ExecutionEnviron::from_compile_environment(env.finalize());
        let em = build_major_machine(ee, cu)?;
        Ok(Self { em: em })
    }
    pub fn march(&mut self) -> Result<Option<MajorValue>, Box<dyn Error>> {
        match werbolg_exec::step(&mut self.em).unwrap() {
            None => Ok(None),
            Some(v) => {
                println!("major: {:?}", v);
                return Ok(Some(v));
            },
        }
    }
}

