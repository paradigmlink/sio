use {
    anyhow::{Result},
    bincode,
    copernica_packets::{
        bloom_filter_index as bfi,
        NarrowWaistPacket, HBFI, PrivateIdentityInterface, PublicIdentity,
        PublicIdentityInterface
    },
    copernica_common::{ Operations, constants::LABEL_SIZE },
    copernica_protocols::{Protocol, TxRx},
    arrayvec::ArrayString,
    log::debug,
    rand::{distributions::Alphanumeric, thread_rng, Rng},
};
static APP_NAME: &str = "locd";
static MOD_HTLC: &str = "htlc";
static FUN_PEER: &str = "peer";
static FUN_PING: &str = "ping";
static ARG_PING: &str = "ping";
#[derive(Clone)]
pub struct LOCD {
    label: ArrayString<LABEL_SIZE>,
    protocol_sid: PrivateIdentityInterface,
    txrx: TxRx,
    ops: Operations,
}
impl LOCD {
    pub fn cyphertext_ping(&mut self, response_pid: PublicIdentity) -> Result<String> {
        let hbfi = HBFI::new(PublicIdentityInterface::new(self.txrx.protocol_pid()?), response_pid, APP_NAME, MOD_HTLC, FUN_PING, ARG_PING)?;
        let mut retries = 5;
        let mut window_timeout = 500;
        let echo: Vec<Vec<u8>> = self.txrx.unreliable_sequenced_request(hbfi.clone(), 0, 0, &mut retries, &mut window_timeout)?;
        let mut result: String = "".into();
        for s in &echo {
            let data: &str = bincode::deserialize(&s)?;
            result.push_str(data);
        }
        Ok(result)
    }
}
impl Protocol for LOCD {
    fn new(protocol_sid: PrivateIdentityInterface, (label, ops): (ArrayString<LABEL_SIZE>, Operations)) -> Self {
        ops.register_protocol(label.clone());
        Self {
            label,
            protocol_sid,
            txrx: TxRx::Inert,
            ops,
        }
    }
    #[allow(unreachable_code)]
    fn run(&self) -> Result<()> {
        let txrx = self.txrx.clone();
        std::thread::spawn(move || {
            let res_check = bfi(&format!("{}", txrx.protocol_pid()?))?;
            let app_check = bfi(APP_NAME)?;
            let m0d_check = bfi(MOD_HTLC)?;
            loop {
                match txrx.clone().next() {
                    Ok(ilp) => {
                        debug!("\t\t\t|  link-to-protocol");
                        let nw: NarrowWaistPacket = ilp.narrow_waist();
                        match nw.clone() {
                            NarrowWaistPacket::Request { hbfi, .. } => match hbfi {
                                HBFI { ref res, ref app, ref m0d, .. }
                                    if (res == &res_check)
                                        && (app == &app_check)
                                        && (m0d == &m0d_check) =>
                                {
                                    match hbfi {
                                        HBFI { ref fun, ref arg, .. }
                                            if (fun == &bfi(FUN_PING)?)
                                                && (arg == &bfi(ARG_PING)?) =>
                                        {
                                            let  echo: Vec<u8> = bincode::serialize(&"ping")?;
                                            txrx.clone().respond(hbfi.clone(), echo)?;
                                        }
                                        _ => {}
                                    }
                                }
                                _ => {}
                            },
                            NarrowWaistPacket::Response { hbfi, .. } => match hbfi {
                                HBFI { app, m0d, fun, arg, .. }
                                    if (app == app_check)
                                        && (m0d == m0d_check)
                                        && (fun == bfi(FUN_PING)?)
                                    => {
                                        match arg {
                                            arg if arg == bfi(ARG_PING)? => {
                                                debug!("\t\t\t|  RESPONSE PACKET ARRIVED");
                                                txrx.unreliable_sequenced_response(ilp)?;
                                            },
                                            _ => {}
                                        }
                                    }
                                _ => {}
                            }
                        }
                    },
                    Err(_e) => {}
                }
            }
            Ok::<(), anyhow::Error>(())
        });
        Ok(())
    }
    fn set_txrx(&mut self, txrx: TxRx) {
        self.txrx = txrx;
    }
    fn get_label(&self) -> ArrayString<LABEL_SIZE> {
        self.label.clone()
    }
    fn get_protocol_sid(&mut self) -> PrivateIdentityInterface {
        self.protocol_sid.clone()
    }
    fn get_ops(&self) -> Operations {
        self.ops.clone()
    }
}
fn secret_generate() -> (String, [u8; 32]) {
    let rand_string: String = thread_rng()
        .sample_iter(&Alphanumeric)
        .take(30)
        .map(char::from)
        .collect();
    use cryptoxide::digest::Digest as _;
    let mut hash = [0; 32];
    let mut b = cryptoxide::blake2b::Blake2b::new(32);
    b.input(&rand_string.as_bytes());
    b.result(&mut hash);
    (rand_string, hash)
}
fn amount() -> (String, [u8; 32]) {
    let rand_string: String = thread_rng()
        .sample_iter(&Alphanumeric)
        .take(30)
        .map(char::from)
        .collect();
    use cryptoxide::digest::Digest as _;
    let mut hash = [0; 32];
    let mut b = cryptoxide::blake2b::Blake2b::new(32);
    b.input(&rand_string.as_bytes());
    b.result(&mut hash);
    (rand_string, hash)
}
