use crate::value::{GeneralValue, MajorValue, CorporalValue};
use werbolg_exec::WAllocator;

pub struct GeneralAllocator;
pub struct MajorAllocator;
pub struct CorporalAllocator;

impl WAllocator for GeneralAllocator {
    type Value = GeneralValue;
}

impl WAllocator for MajorAllocator {
    type Value = MajorValue;
}

impl WAllocator for CorporalAllocator {
    type Value = CorporalValue;
}
