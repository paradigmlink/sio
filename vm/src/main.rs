extern crate pest;
use {
    sio_vm::parse::parse,
    std::fs,
};
fn main() -> Result<(), Box<dyn std::error::Error>> {
    let raw_src = String::from_utf8(fs::read("vm/examples/module_def.sio")?)?;
    println!("source: {}", raw_src);
    let typed_ast = parse(raw_src);
    println!("typed ast: {:?}", typed_ast);
    Ok(())
}
