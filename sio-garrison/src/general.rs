use sio::{
    GeneralExecutionMachine, GeneralEnvironment, GeneralAllocator, GeneralLiteral, GeneralState, GeneralValue, general_literal_mapper, general_literal_to_value
};
use werbolg_core::{AbsPath, Ident, Namespace, ir::Module};
use werbolg_exec::{ExecutionMachine, ExecutionEnviron, ExecutionParams, WerRefCount};
use werbolg_compile::{compile};
use werbolg_lang_common::{Report, ReportKind, Source};
use alloc::{format, vec, boxed::Box, string::String};
use core::error::Error;
use crate::{report_print, run_frontend};


fn compile_general(
    //params: SioParams,
    env: &mut GeneralEnvironment,
    source: Source,
    module: Module,
) -> Result<werbolg_compile::CompilationUnit<GeneralLiteral>, Box<dyn Error>> {
    //let (source, module) = run_frontend(src, path).unwrap();
    let module_ns = Namespace::root().append(Ident::from("main"));
    let modules = vec![(module_ns.clone(), module)];
    let compilation_params = werbolg_compile::CompilationParams {
        literal_mapper: general_literal_mapper,
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

pub fn build_general_machine (
    ee: ExecutionEnviron<GeneralAllocator, GeneralLiteral, GeneralState, GeneralValue>,
    cu: werbolg_compile::CompilationUnit<GeneralLiteral>,
) -> Result<GeneralExecutionMachine, Box<dyn Error>> {
    let module_ns = Namespace::root().append(Ident::from("main"));
    let entry_point = cu
        .funs_tbl
        .get(&AbsPath::new(&module_ns, &Ident::from("main")))
        .expect("existing function as entry point");
    let execution_params = ExecutionParams {
        literal_to_value: general_literal_to_value,
    };
    let state = GeneralState {};
    let allocator = GeneralAllocator {};
    let mut em = ExecutionMachine::new(
        WerRefCount::new(cu),
        WerRefCount::new(ee),
        execution_params, allocator, state);
    werbolg_exec::initialize(&mut em, entry_point, &[]).unwrap();
    Ok(em)
}

pub struct General {
    em: GeneralExecutionMachine,
}

impl General {
    pub fn new(
        src: String,
        path: String,
        //params: SioParams,
        mut env: GeneralEnvironment,
    ) -> Result<Self, Box<dyn Error>> {
        let (source, module) = run_frontend(src, path)?;
        let cu = compile_general(/*params, */ &mut env, source, module)?;
        let ee = werbolg_exec::ExecutionEnviron::from_compile_environment(env.finalize());
        let em = build_general_machine(ee, cu)?;
        Ok(Self { em: em })
    }
    pub fn march(&mut self) -> Result<Option<GeneralValue>, Box<dyn Error>> {
        match werbolg_exec::step(&mut self.em).unwrap() {
            None => Ok(None),
            Some(v) => {
                println!("general: {:?}", v);
                return Ok(Some(v));
            },
        }
    }
}



#[cfg(test)]
mod general_tests {
    //use alloc::vec::Vec;
    //use alloc::vec;
    use alloc::string::ToString;
    use sio::{create_general_env};
    use super::*;
    static src: &str =
        "
        url public_key : sio79f708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03abd;
        url type : src;
        url name : app_name;
        url app : public_key::type::name;
        general app::General {
            url g0: siopub00119a708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03abdabca;
            url g1: siopub00129a708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03abdabcb;
            url g2: siopub00139a708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03abdabcc;
            url g3: siopub00149a708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03abdabcd;
            url g4: siopub00159a708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03abdabce;
            url g5: siopub00169a708c25a23ed367610facc14035adc7ba4b1bfa9252ef55c6c24f1b9b03abdabcf;
            install_brigadier :: (garrison: pid, subordinate: pid) -> pid {
                let pid = spawn(app::Brigadier::main::(subordinate), garrison);
                pid;
            }
            main :: () {
                let b0, b1, b2, b3, b4, b5;
                subordinate(b0, b1);
                subordinate(b1, b2);
                subordinate(b3, b4);
                subordinate(b4, b5);
                b0 = install_brigadier(g0, b1);
                b1 = install_brigadier(g1, b2);
                b2 = install_brigadier(g2, nil);
                b3 = install_brigadier(g3, b4);
                b4 = install_brigadier(g4, b5);
                b5 = install_brigadier(b5, nil); 
                let brigadier_standby = [
                    b0, b1
                ];
                supervise_standby(brigadier_standby);
            }
        }
        ";

    #[test]
    fn basic_general_test() {
        let env = create_general_env();
        let mut corporal = General::new(src.to_string(), "/".to_string(), env).expect("General failure reason:");
        corporal.march();
        assert_eq!(4, 4);
    }
}
