#![feature(type_alias_impl_trait)]

use embassy::executor::Spawner;
use embassy::time::{Duration, Timer};
use sio_vm::{tick};
use log::*;


#[embassy::task]
pub async fn run_here() {
    loop {
        Timer::after(Duration::from_secs(1)).await;
        info!("{}", tick().await);
    }
}

#[embassy::main]
async fn main(spawner: Spawner) {
    env_logger::builder()
        .filter_level(log::LevelFilter::Debug)
        .format_timestamp_nanos()
        .init();

    spawner.spawn(run_here()).unwrap();
}
