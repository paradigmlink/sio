//#![no_std]
extern crate alloc;
pub mod allocator;
pub mod environ;
pub mod value;

use werbolg_core::{Ident, Literal, Module, Namespace};
pub use self::{
    allocator::{GeneralAllocator, MajorAllocator, CorporalAllocator},
    value::{GeneralValue, MajorValue, CorporalValue},
    environ::{general::GeneralLiteral, major::MajorLiteral, corporal::CorporalLiteral},
};

pub type GeneralNIF<'m, 'e> = werbolg_exec::NIF<'m, 'e, GeneralAllocator, GeneralLiteral, GeneralState, GeneralValue>;
pub type GeneralEnvironment<'m, 'e> = werbolg_compile::Environment<GeneralNIF<'m, 'e>, GeneralValue>;
pub type GeneralExecutionMachine<'m, 'e> =
    werbolg_exec::ExecutionMachine<'m, 'e, GeneralAllocator, GeneralLiteral, GeneralState, GeneralValue>;

#[derive(Clone)]
pub struct GeneralState {}

#[derive(Clone)]
pub struct MajorState {}

#[derive(Clone)]
pub struct CorporalState {}
