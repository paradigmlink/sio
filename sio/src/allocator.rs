use crate::value::{GeneralValue, BrigadierValue, MajorValue, CorporalValue};
use werbolg_exec::WAllocator;

pub struct GeneralAllocator;
pub struct BrigadierAllocator;
pub struct MajorAllocator;
pub struct CorporalAllocator;

impl WAllocator for GeneralAllocator {
    type Value = GeneralValue;
}

impl WAllocator for BrigadierAllocator {
    type Value = BrigadierValue;
}

impl WAllocator for MajorAllocator {
    type Value = MajorValue;
}

impl WAllocator for CorporalAllocator {
    type Value = CorporalValue;
}
