use sio::{
    BrigadierExecutionMachine, BrigadierEnvironment, BrigadierAllocator, BrigadierLiteral, BrigadierState, BrigadierValue, brigadier_literal_mapper, brigadier_literal_to_value,
    MajorExecutionMachine, MajorEnvironment, MajorLiteral,
    CorporalExecutionMachine, CorporalEnvironment, CorporalLiteral};
use sio::environ::brigadier::create_brigadier_env;
use werbolg_core::{id::IdF, AbsPath, Ident, Namespace, ir::Module, Path};
use werbolg_exec::{NIF, ExecutionMachine, ExecutionEnviron, ExecutionParams, WerRefCount};
use werbolg_compile::{CompilationUnit, Environment, compile, code_dump, InstructionAddress};
use werbolg_lang_common::{Report, ReportKind, Source};
use werbolg_lang_lispy::module;
use alloc::{string::ToString, format, vec, vec::Vec, boxed::Box, string::String};
use core::error::Error;
use crate::{SioParams, report_print, run_frontend};


fn compile_brigadier(
    params: SioParams,
    env: &mut BrigadierEnvironment,
    source: Source,
    module: Module,
) -> Result<werbolg_compile::CompilationUnit<BrigadierLiteral>, Box<dyn Error>> {
    //let (source, module) = run_frontend(src, path).unwrap();
    let module_ns = Namespace::root().append(Ident::from("main"));
    let modules = vec![(module_ns.clone(), module)];
    let compilation_params = werbolg_compile::CompilationParams {
        literal_mapper: brigadier_literal_mapper,
        sequence_constructor: None,
    };
    let mut cu = match compile(&compilation_params, modules, env) {
        Err(e) => {
            let report = Report::new(ReportKind::Error, format!("Compilation Error: {:?}", e))
                .lines_before(1)
                .lines_after(1)
                .highlight(e.span(), format!("compilation error here"));
            report_print(&source, report)?;
            return Err(format!("compilation error {:?}", e).into());
        }
        Ok(m) => m,
    };
    if params.dump_instr {
        let mut out = String::new();
        code_dump(&mut out, &cu.code, &cu.funs).expect("writing to string work");
        //println!("{}", out);
    }
    Ok(cu)
}

pub fn build_brigadier_machine (
    ee: ExecutionEnviron<BrigadierAllocator, BrigadierLiteral, BrigadierState, BrigadierValue>,
    cu: werbolg_compile::CompilationUnit<BrigadierLiteral>,
) -> Result<BrigadierExecutionMachine, Box<dyn Error>> {
    let module_ns = Namespace::root().append(Ident::from("main"));
    let entry_point = cu
        .funs_tbl
        .get(&AbsPath::new(&module_ns, &Ident::from("main")))
        .expect("existing function as entry point");
    let execution_params = ExecutionParams {
        literal_to_value: brigadier_literal_to_value,
    };
    let mut state = BrigadierState {};
    let mut allocator = BrigadierAllocator {};
    let mut em = ExecutionMachine::new(
        WerRefCount::new(cu),
        WerRefCount::new(ee),
        execution_params, allocator, state);
    werbolg_exec::initialize(&mut em, entry_point, &[]).unwrap();
    Ok(em)
}

pub struct Brigadier {
    em: BrigadierExecutionMachine,
}

impl  Brigadier {
    pub fn new(
        src: String,
        path: String,
        params: SioParams,
        user_env: &mut BrigadierEnvironment,
    ) -> Result<Self, Box<dyn Error>> {
        let (source, module) = run_frontend(src, path)?;
        let mut env = create_brigadier_env();
        let cu = compile_brigadier(params, &mut env, source, module)?;
        let ee = werbolg_exec::ExecutionEnviron::from_compile_environment(env.finalize());
        let em = build_brigadier_machine(ee, cu)?;
        Ok(Self { em: em })
    }
    pub fn march(&mut self) {
        werbolg_exec::step(&mut self.em);
    }
}

