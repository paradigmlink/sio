use {
    pest::{
        iterators::Pairs,
        Parser,
    },
    sio_syntax::{SioParser, Rule},
    crate::ast::SioAst,
};
pub fn parse(raw_str: String) -> Result<SioAst, Box<dyn std::error::Error>> {
    let untyped_sio_parse_tree = SioParser::parse(Rule::module_def, &raw_str)?;
    let ast: SioAst = typed_sio_ast(untyped_sio_parse_tree);
    Ok(ast)
}
fn typed_sio_ast(_untyped_ast: Pairs<Rule>) -> SioAst {
    SioAst::new()
}
