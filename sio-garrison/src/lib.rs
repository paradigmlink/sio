#![no_std]

extern crate alloc;
use sio::{
    BrigadierExecutionMachine, BrigadierEnvironment, BrigadierLiteral,
    MajorExecutionMachine, MajorEnvironment, MajorLiteral,
    CorporalExecutionMachine, CorporalEnvironment, CorporalLiteral};
use sio_frontend::parse;
use hashbrown::HashMap;
use alloc::vec::Vec;
use alloc::vec;
use werbolg_core::{ir::Module, Path};
use werbolg_compile::CompilationUnit;

pub struct Brigadier<'m, 'a> {
    cu: Option<CompilationUnit<BrigadierLiteral>>,
    env: Option<BrigadierEnvironment<'m, 'a>>,
    brigadier: Option<BrigadierExecutionMachine<'m, 'a>>,
}

impl <'m, 'a> Brigadier<'m, 'a> {
    pub fn new(src: &str) -> Self {
        Self {
            cu: None,
            env: None,
            brigadier: None,
        }
    }
    pub fn env(&mut self, env: BrigadierEnvironment<'m, 'a>) {
        self.env = Some(env);
    }
    pub fn march(&mut self) {
        if let Some(brigadier) = &mut self.brigadier {
            werbolg_exec::step(brigadier);
        }
    }
}

pub struct Major<'m, 'a> {
    cu: Option<CompilationUnit<MajorLiteral>>,
    env: Option<MajorEnvironment<'m, 'a>>,
    major: Option<MajorExecutionMachine<'m, 'a>>,
}

impl <'m, 'a> Major<'m, 'a> {
    pub fn new() -> Self {
        Self {
            cu: None,
            env: None,
            major: None,
        }
    }
    pub fn env(&mut self, env: MajorEnvironment<'m, 'a>) {
        self.env = Some(env);
    }
    pub fn march(&mut self) {
        if let Some(major) = &mut self.major {
            werbolg_exec::step(major);
        }
    }
}

pub struct Corporal<'m, 'a> {
    cu: Option<CompilationUnit<CorporalLiteral>>,
    env: Option<CorporalEnvironment<'m, 'a>>,
    threads: Vec<CorporalExecutionMachine<'m, 'a>>,
}

impl <'m, 'a> Corporal<'m, 'a> {
    pub fn new() -> Self {
        Self {
            cu: None,
            env: None,
            threads: vec![],
        }
    }
    pub fn env(&mut self, env: CorporalEnvironment<'m, 'a>) {
        self.env = Some(env);
    }
    pub fn march(&mut self) {
        for thread in &mut self.threads {
            werbolg_exec::step(thread);
        }
    }
}

pub struct Garrison<'m, 'a> {
    brigadier: Option<Brigadier<'m, 'a>>,
    majors: Vec<Major<'m, 'a>>,
    corporals: Vec<Corporal<'m, 'a>>,
}

impl <'m, 'a> Garrison<'m, 'a> {
    pub fn new() -> Self {
        Self {
            brigadier: None,
            majors: vec![],
            corporals: vec![],
        }
    }
    pub fn brigadier(&mut self, brigadier: Brigadier<'m, 'a>) {
        self.brigadier = Some(brigadier);
    }
    pub fn add_major(&mut self, major: Major<'m, 'a>) {
        self.majors.push(major);
    }
    pub fn add_corporal(&mut self, corporal: Corporal<'m, 'a>) {
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
