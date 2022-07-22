#![no_std]
#![feature(type_alias_impl_trait)]

use embassy::time::{Duration, Timer};
use log::*;

pub async fn tick() {
    info!("tick");
    Timer::after(Duration::from_secs(1)).await;
}



