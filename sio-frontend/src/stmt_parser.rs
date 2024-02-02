use alloc::vec;
use alloc::vec::Vec;
use alloc::boxed::Box;
use alloc::format;
use crate::{
    ast::*,
    token::*,
    common::*,
    parser::Parser,
    position::Span,
    position::WithSpan,
};

fn parse_program(it: &mut Parser) -> Result<Vec<WithSpan<Stmt>>, ()> {
    let mut statements = Vec::new();
    while !it.is_eof() {
        statements.push(parse_module_declaration(it)?);
    }

    Ok(statements)
}

fn parse_module_declaration(it: &mut Parser) -> Result<WithSpan<Stmt>, ()> {
    match it.peek() {
        TokenKind::Url => parse_url_declaration(it),
        TokenKind::Corporal => parse_corporal_declaration(it),
        TokenKind::Major => parse_major_declaration(it),
        TokenKind::Brigadier => parse_brigadier_declaration(it),
        _ => {
            it.error(&format!("Unexpected {}", it.peek_token().value), it.peek_token().span);
            Err(())
        },
    }
}

fn parse_url_declaration(it: &mut Parser) -> Result<WithSpan<Stmt>, ()> {
    todo!();
}

fn parse_corporal_declaration(it: &mut Parser) -> Result<WithSpan<Stmt>, ()> {
    todo!();
}

fn parse_major_declaration(it: &mut Parser) -> Result<WithSpan<Stmt>, ()> {
    todo!();
}

fn parse_brigadier_declaration(it: &mut Parser) -> Result<WithSpan<Stmt>, ()> {
    todo!();
}

fn parse_declaration(it: &mut Parser) -> Result<WithSpan<Stmt>, ()> {
    match it.peek() {
        //TokenKind::Var => parse_var_declaration(it),
        TokenKind::Fun => parse_function_declaration(it),
        _ => parse_statement(it),
    }
}

fn parse_statement(it: &mut Parser) -> Result<WithSpan<Stmt>, ()> {
    match it.peek() {
        TokenKind::Print => parse_print_statement(it),
        TokenKind::If => parse_if_statement(it),
        TokenKind::LeftBrace => parse_block_statement(it),
        TokenKind::Use => parse_use_statement(it),
        _ => parse_expr_statement(it),
    }
}

fn parse_function_declaration(it: &mut Parser) -> Result<WithSpan<Stmt>, ()> {
    let begin_span = it.expect(TokenKind::Fun)?;
    let fun = parse_function(it)?;

    let span = Span::union(begin_span, &fun);
    Ok(WithSpan::new(fun.value, span))
}

fn parse_function(it: &mut Parser) -> Result<WithSpan<Stmt>, ()> {
    let name = expect_identifier(it)?;
    it.expect(TokenKind::LeftParen)?;
    let params = if !it.check(TokenKind::RightParen) {
        parse_params(it)?
    } else {
        Vec::new()
    };
    it.expect(TokenKind::RightParen)?;
    it.expect(TokenKind::LeftBrace)?;
    let mut body: Vec<WithSpan<Stmt>> = Vec::new();
    while !it.check(TokenKind::RightBrace) {
        body.push(parse_declaration(it)?);
    }
    let end_span = it.expect(TokenKind::RightBrace)?;
    Ok(WithSpan::new(Stmt::Function(name.clone(), params, body), Span::union(&name, end_span)))
}

fn parse_use_statement(it: &mut Parser) -> Result<WithSpan<Stmt>, ()> {
    let begin_span = it.expect(TokenKind::Use)?;
    let name = expect_string(it)?;
    todo!();
}

fn parse_params(it: &mut Parser) -> Result<Vec<WithSpan<Identifier>>, ()> {
    let mut params: Vec<WithSpan<Identifier>> = Vec::new();
    params.push(expect_identifier(it)?);
    while it.check(TokenKind::Comma) {
        it.expect(TokenKind::Comma)?;
        params.push(expect_identifier(it)?);
    }
    Ok(params)
}

fn parse_expr_statement(it: &mut Parser) -> Result<WithSpan<Stmt>, ()> {
    let expr = parse_expr(it)?;
    let end_span = it.expect(TokenKind::Semicolon)?;

    let span = Span::union(&expr, end_span);
    Ok(WithSpan::new(Stmt::Expression(Box::new(expr)), span))
}

fn parse_block_statement(it: &mut Parser) -> Result<WithSpan<Stmt>, ()> {
    let begin_span = it.expect(TokenKind::LeftBrace)?;
    let mut statements: Vec<WithSpan<Stmt>> = Vec::new();
    while !it.check(TokenKind::RightBrace) {
        statements.push(parse_declaration(it)?);
    }
    let end_span = it.expect(TokenKind::RightBrace)?;
    Ok(WithSpan::new(Stmt::Block(statements), Span::union(begin_span, end_span)))
}

fn parse_if_statement(it: &mut Parser) -> Result<WithSpan<Stmt>, ()> {
    let begin_token = it.expect(TokenKind::If)?;
    it.expect(TokenKind::LeftParen)?;
    let condition = parse_expr(it)?;
    it.expect(TokenKind::RightParen)?;
    let if_stmt = parse_statement(it)?;
    let mut end_span = if_stmt.span;
    let mut else_stmt: Option<WithSpan<Stmt>> = None;

    if it.optionally(TokenKind::Else)? {
        let stmt = parse_statement(it)?;
        end_span = stmt.span;
        else_stmt = Some(stmt);
    }

    Ok(WithSpan::new(Stmt::If(
        Box::new(condition),
        Box::new(if_stmt),
        else_stmt.map(Box::new),
    ), Span::union_span(begin_token.span, end_span)))
}

fn parse_var_declaration(it: &mut Parser) -> Result<WithSpan<Stmt>, ()> {
    let begin_span = it.expect(TokenKind::Let)?;
    let name = expect_identifier(it)?;
    let mut initializer = None;

    if it.optionally(TokenKind::Equal)? {
        initializer = Some(parse_expr(it)?);
    }

    let end_span = it.expect(TokenKind::Semicolon)?;

    Ok(WithSpan::new(Stmt::Let(name, initializer.map(Box::new)), Span::union(begin_span, end_span)))
}

fn parse_expr(it: &mut Parser) -> Result<WithSpan<Expr>, ()> {
    super::expr_parser::parse(it)
}

fn parse_print_statement(it: &mut Parser) -> Result<WithSpan<Stmt>, ()> {
    let begin_token = it.expect(TokenKind::Print)?;
    let expr = parse_expr(it)?;
    let end_token = it.expect(TokenKind::Semicolon)?;
    Ok( WithSpan::new(Stmt::Print(Box::new(expr)), Span::union(begin_token, end_token)) )
}

pub fn parse(it: &mut Parser) -> Result<Vec<WithSpan<Stmt>>, ()> {
    parse_program(it)
}

#[cfg(test)]
mod tests {
    use core::ops::Range;
    use alloc::string::String;
    use crate::position::Diagnostic;

    use super::super::tokenizer::*;
    use super::*;
    fn parse_str(data: &str) -> Result<Vec<WithSpan<Stmt>>, Vec<Diagnostic>> {
        let tokens = tokenize_with_context(data);
        let mut parser = crate::parser::Parser::new(&tokens);
        match parse(&mut parser) {
            Ok(ast) => Ok(ast),
            Err(_) => Err(parser.diagnostics().to_vec()),
        }
    }

    pub fn ws<T>(value: T, range: Range<u32>) -> WithSpan<T> {
        unsafe { WithSpan::new_unchecked(value, range.start, range.end) }
    }

    fn assert_errs(data: &str, errs: &[&str]) {
        let x = parse_str(data);
        assert!(x.is_err());
        let diagnostics = x.unwrap_err();
        for diag in diagnostics {
            assert!(errs.contains(&&diag.message.as_str()), "{}", diag.message);
        }
    }

    #[test]
    fn test_expr_stmt() {
        assert_eq!(
            parse_str("nil;"),
            Ok(vec![
                ws(Stmt::Expression(Box::new(ws(Expr::Nil, 0..3))), 0..4)
            ])
        );
        assert_eq!(
            parse_str("nil;nil;"),
            Ok(vec![
                ws(Stmt::Expression(Box::new(ws(Expr::Nil, 0..3))), 0..4),
                ws(Stmt::Expression(Box::new(ws(Expr::Nil, 4..7))), 4..8),
            ])
        );
    }

    #[test]
    fn test_print_stmt() {
        assert_eq!(
            parse_str("print nil;"),
            Ok(vec![
                ws(Stmt::Print(Box::new(ws(Expr::Nil, 6..9))), 0..10),
            ])
        );
    }

    fn make_span_string(string: &str, offset: u32) -> WithSpan<String> {
        unsafe { WithSpan::new_unchecked(string.into(), offset, offset+string.len() as u32) }
    }

    #[test]
    fn test_var_decl() {
        assert_eq!(
            parse_str("var beverage;"),
            Ok(vec![
                ws(Stmt::Let(make_span_string("beverage", 4), None), 0..13),
            ])
        );
        assert_eq!(
            parse_str("var beverage = nil;"),
            Ok(vec![
                ws(Stmt::Let(
                    make_span_string("beverage", 4),
                    Some(Box::new(ws(Expr::Nil, 15..18)))
                ), 0..19),
            ])
        );

        unsafe {
            assert_eq!(
                parse_str("var beverage = x = nil;"),
                Ok(vec![
                    ws(Stmt::Let(
                        make_span_string("beverage", 4),
                        Some(Box::new(ws(Expr::Assign(
                            WithSpan::new_unchecked("x".into(), 15, 16),
                            Box::new(ws(Expr::Nil, 19..22))
                        ), 15..22)))
                    ), 0..23),
                ])
            );
        }

        assert_errs("if (nil) var beverage = nil;", &["Unexpected 'var'"]);
    }

    #[test]
    fn test_if_stmt() {
        assert_eq!(
            parse_str("if(nil) print nil;"),
            Ok(vec![
                ws(Stmt::If(
                    Box::new(ws(Expr::Nil, 3..6)),
                    Box::new(ws(Stmt::Print(Box::new(ws(Expr::Nil, 14..17))), 8..18)),
                    None,
                ), 0..18),
            ])
        );
        assert_eq!(
            parse_str("if(nil) print nil; else print false;"),
            Ok(vec![
                ws(Stmt::If(
                    Box::new(ws(Expr::Nil, 3..6)),
                    Box::new(ws(Stmt::Print(Box::new(ws(Expr::Nil, 14..17))), 8..18)),
                    Some(Box::new(
                        ws(Stmt::Print(Box::new(ws(Expr::Boolean(false), 30..35))), 24..36),
                    )),
                ), 0..36),
            ])
        );
    }

    #[test]
    fn test_block_stmt() {
        assert_eq!(parse_str("{}"), Ok(vec![
            ws(Stmt::Block(vec![]), 0..2),
        ]));
        assert_eq!(
            parse_str("{nil;}"),
            Ok(vec![
                ws(Stmt::Block(vec![
                    ws(Stmt::Expression(Box::new(
                        ws(Expr::Nil, 1..4)
                    )), 1..5),
                ]), 0..6),
            ])
        );
        assert_eq!(
            parse_str("{nil;nil;}"),
            Ok(vec![
                ws(Stmt::Block(vec![
                    ws(Stmt::Expression(Box::new(ws(Expr::Nil, 1..4))), 1..5),
                    ws(Stmt::Expression(Box::new(ws(Expr::Nil, 5..8))), 5..9),
                ]), 0..10),
            ])
        );
    }

    #[test]
    fn test_use_stmt() {
        assert_eq!(parse_str("use \"mymodule\";"), Ok(vec![
            ws(Stmt::Use(
                ws("mymodule".into(), 7..17),
                None
            ), 0..18),
        ]));

        assert_eq!(parse_str("import \"mymodule\" for message;"), Ok(vec![
            ws(Stmt::Use(
                ws("mymodule".into(), 7..17),
                Some(vec![
                    ws("message".into(), 22..29),
                ])
            ), 0..30),
        ]));
    }

    #[test]
    fn test_function_stmt() {
        unsafe {
            assert_eq!(
                parse_str("fun test(){}"),
                Ok(vec![
                    ws(Stmt::Function(
                        WithSpan::new_unchecked("test".into(), 4, 8),
                        vec![],
                        vec![]
                    ), 0..12),
                ])
            );
            assert_eq!(
                parse_str("fun test(a){}"),
                Ok(vec![
                    ws(Stmt::Function(
                        WithSpan::new_unchecked("test".into(), 4, 8),
                        vec![WithSpan::new_unchecked("a".into(), 9, 10)],
                        vec![]
                    ), 0..13),
                ])
            );
            assert_eq!(
                parse_str("fun test(){nil;}"),
                Ok(vec![
                    ws(Stmt::Function(
                        WithSpan::new_unchecked("test".into(), 4, 8),
                        vec![],
                        vec![ws(Stmt::Expression(Box::new(ws(Expr::Nil, 11..14))), 11..15),]
                    ), 0..16),
                ])
            );
        }
    }
}
