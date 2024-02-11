#![no_std]
#![feature(error_in_core)]

use hashbrown::{HashMap, HashSet};
extern crate alloc;
use sio::{
    BrigadierExecutionMachine, BrigadierEnvironment, BrigadierAllocator, BrigadierLiteral, BrigadierState, BrigadierValue, brigadier_literal_mapper, brigadier_literal_to_value,
    MajorExecutionMachine, MajorEnvironment, MajorLiteral,
    CorporalExecutionMachine, CorporalEnvironment, CorporalLiteral};
use sio::environ::brigadier::create_brigadier_env;
use sio_frontend::parse;
use werbolg_core::{id::IdF, AbsPath, Ident, Namespace, ir::Module, Path};
use werbolg_compile::{CompilationUnit, Environment, compile, code_dump, InstructionAddress};
use werbolg_exec::{NIF, ExecutionMachine, ExecutionEnviron, ExecutionParams, WerRefCount};
use werbolg_lang_common::{Report, ReportKind, Source};
use werbolg_lang_lispy::module;
use alloc::{string::ToString, format, vec, vec::Vec, boxed::Box, string::String};
use core::error::Error;

mod brigadier;
mod major;
mod corporal;
use brigadier::Brigadier;
use major::Major;
use corporal::Corporal;

pub struct SioParams {
    pub dump_ir: bool,
    pub dump_instr: bool,
    pub exec_step_trace: bool,
    pub step_address: Vec<u64>,
}

pub fn report_print(source: &Source, report: Report) -> Result<(), Box<dyn Error>> {
    let mut s = String::new();
    report.write(&source, &mut s)?;
    //println!("{}", s);
    Ok(())
}

fn run_frontend(src: String, path: String) -> Result<(Source, Module), Box<dyn Error>> {
    let source = Source::from_string(path, src);
    let parsing_res = werbolg_lang_lispy::module(&source.file_unit);
    let module = match parsing_res {
        Err(es) => {
            for e in es.into_iter() {
                let report = Report::new(ReportKind::Error, format!("Parse Error: {:?}", e))
                    .lines_before(1)
                    .lines_after(1)
                    .highlight(e.location, format!("parse error here"));

                report_print(&source, report)?;
            }
            return Err(format!("parse error").into());
        }
        Ok(module) => module,
    };
    Ok((source, module))
}

pub struct Garrison {
    brigadier: Option<Brigadier>,
    majors: Vec<Major>,
    corporals: Vec<Corporal>,
}

impl Garrison {
    pub fn new() -> Self {
        Self {
            brigadier: None,
            majors: vec![],
            corporals: vec![],
        }
    }
    pub fn brigadier(&mut self, brigadier: Brigadier) {
        self.brigadier = Some(brigadier);
    }
    pub fn add_major(&mut self, major: Major) {
        self.majors.push(major);
    }
    pub fn add_corporal(&mut self, corporal: Corporal) {
        self.corporals.push(corporal);
    }
    pub fn march(&mut self) {
        if let Some(brigadier) = &mut self.brigadier {
            brigadier.march();
            for major in &mut self.majors {
                major.march();
            }
            for corporal in &mut self.corporals {
                corporal.march();
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let mut garrison = Garrison::new();
        garrison.march();
        assert_eq!(4, 4);
    }
}
