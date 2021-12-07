use {
    sio_vm::{self, Parser},
    ariadne::{Report, ReportKind, Label, Source},
};

fn main() {
    let src = "
        let three = 3;
        let eight = 5 + three;
        add :: (x y) {
            x + y
        };
        let eleven add(three, eight);
        divide :: (k z) {
            k / z
        };
        divide(eleven, 11)
    ";

    let _src = "
        let a b c d in {
            a = 11
            b = 2
            c = a + b
            d = c * c
        }
    ";

    match sio_vm::parser().parse(src) {
        Ok(ast) => match sio_vm::eval(&ast, &mut Vec::new(), &mut Vec::new()) {
            Ok(output) => println!("{}", output),
            Err(eval_err) => println!("Evaluation error: {}", eval_err),
        },
        Err(parse_errs) => {
            parse_errs
                .into_iter()
                .for_each(|e| {
                    Report::build(ReportKind::Error, (), 34)
                        .with_message(format!("{:?}", e.reason()))
                        .with_label(Label::new(e.span())
                        .with_message(format!("Reason: {:?}, Expected: {:#?}, Found: {:?}"
                            , e.reason()
                            , e.expected().into_iter().map(|expected| expected.to_string()) .collect::<Vec<_>>() .join(", ")
                            , e.found())))
                        .finish()
                        .print(Source::from(src))
                        .unwrap();
                });
        }
    }
}
