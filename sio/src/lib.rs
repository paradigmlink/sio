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


pub type MajorNIF<'m, 'e> = werbolg_exec::NIF<'m, 'e, MajorAllocator, MajorLiteral, MajorState, MajorValue>;
pub type MajorEnvironment<'m, 'e> = werbolg_compile::Environment<MajorNIF<'m, 'e>, MajorValue>;
pub type MajorExecutionMachine<'m, 'e> =
    werbolg_exec::ExecutionMachine<'m, 'e, MajorAllocator, MajorLiteral, MajorState, MajorValue>;

pub type CorporalNIF<'m, 'e> = werbolg_exec::NIF<'m, 'e, CorporalAllocator, CorporalLiteral, CorporalState, CorporalValue>;
pub type CorporalEnvironment<'m, 'e> = werbolg_compile::Environment<CorporalNIF<'m, 'e>, CorporalValue>;
pub type CorporalExecutionMachine<'m, 'e> =
    werbolg_exec::ExecutionMachine<'m, 'e, CorporalAllocator, CorporalLiteral, CorporalState, CorporalValue>;

#[derive(Clone)]
pub struct BrigadierState {}

#[derive(Clone)]
pub struct MajorState {}

#[derive(Clone)]
pub struct CorporalState {}
