#![feature(type_alias_impl_trait)]

use embassy::executor::Spawner;
use sio_vm::{tick};


#[embassy::task]
pub async fn run_here() {
    loop {
        tick().await;
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
