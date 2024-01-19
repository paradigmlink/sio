#![no_std]
extern crate alloc;
pub mod allocator;
pub mod environ;
pub mod value;

use werbolg_core::{Ident, Literal, Module, Namespace};
pub use self::{
    allocator::{BrigadierAllocator, MajorAllocator, CorporalAllocator},
    value::{BrigadierValue, MajorValue, CorporalValue},
    environ::{brigadier::BrigadierLiteral, major::MajorLiteral, corporal::CorporalLiteral},
};

pub type BrigadierNIF<'m, 'e> = werbolg_exec::NIF<'m, 'e, BrigadierAllocator, BrigadierLiteral, BrigadierState, BrigadierValue>;
pub type BrigadierEnvironment<'m, 'e> = werbolg_compile::Environment<BrigadierNIF<'m, 'e>, BrigadierValue>;
pub type BrigadierExecutionMachine<'m, 'e> =
    werbolg_exec::ExecutionMachine<'m, 'e, BrigadierAllocator, BrigadierLiteral, BrigadierState, BrigadierValue>;

#[derive(Clone)]
pub struct BrigadierState {}

#[derive(Clone)]
pub struct MajorState {}

#[derive(Clone)]
pub struct CorporalState {}
