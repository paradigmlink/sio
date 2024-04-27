#![no_std]
extern crate alloc;
pub mod allocator;
pub mod environ;
pub mod value;

pub use self::{
    allocator::{BrigadierAllocator, MajorAllocator, CorporalAllocator},
    value::{BrigadierValue, MajorValue, CorporalValue},
    environ::{
        brigadier::{BrigadierLiteral, brigadier_literal_mapper, brigadier_literal_to_value, create_brigadier_env},
        major::{MajorLiteral, major_literal_mapper, major_literal_to_value, create_major_env},
        corporal::{CorporalLiteral, corporal_literal_mapper, corporal_literal_to_value, create_corporal_env},
    },
};

pub type BrigadierNIF = werbolg_exec::NIF<BrigadierAllocator, BrigadierLiteral, BrigadierState, BrigadierValue>;
pub type BrigadierEnvironment = werbolg_compile::Environment<BrigadierNIF, BrigadierValue>;
pub type BrigadierExecutionMachine =
    werbolg_exec::ExecutionMachine<BrigadierAllocator, BrigadierLiteral, BrigadierState, BrigadierValue>;

pub type MajorNIF = werbolg_exec::NIF<MajorAllocator, MajorLiteral, MajorState, MajorValue>;
pub type MajorEnvironment = werbolg_compile::Environment<MajorNIF, MajorValue>;
pub type MajorExecutionMachine =
    werbolg_exec::ExecutionMachine<MajorAllocator, MajorLiteral, MajorState, MajorValue>;

pub type CorporalNIF = werbolg_exec::NIF<CorporalAllocator, CorporalLiteral, CorporalState, CorporalValue>;
pub type CorporalEnvironment = werbolg_compile::Environment<CorporalNIF, CorporalValue>;
pub type CorporalExecutionMachine =
    werbolg_exec::ExecutionMachine<CorporalAllocator, CorporalLiteral, CorporalState, CorporalValue>;

#[derive(Clone)]
pub struct BrigadierState {}

#[derive(Clone)]
pub struct MajorState {}

#[derive(Clone)]
pub struct CorporalState {}
