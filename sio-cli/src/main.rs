use std::error::Error;

mod args;
mod exec;
mod params;

use sio::{
    create_brigadier_env,
    create_major_env,
    create_corporal_env,
};
use sio_garrison::{Garrison, Brigadier, Major, Corporal};
use exec::*;
use params::{Frontend, SioParams};

#[derive(Clone, Debug, PartialEq, Eq)]
enum Flag {
    Help,
    Version,
    DumpIr,
    DumpInstr,
    ExecStepTrace,
    StepAddress(u64),
    Frontend(Frontend),
}

fn version() {
    println!("v0.1.0")
}

fn help() {
    println!(
        r#"
usage: werbolg-tales [options] <file>

Options:
  --help              Print this help
  --version           Print the version of werbolg-tales
  --dump-ir           Dump the IR on stdout
  --dump-instr        Dump the Code Instructions on stdout
  --exec-step-trace   Trace every step of execution
  --step-address <a>  Address to print a debug trace
  --frontend <value>  Set the frontend to use a specific frontend
    "#
    );
}

fn main() -> Result<(), Box<dyn Error>> {
    let options = args::ArgOptions {
        short: &[],
        long: &[
            ("help", args::FlagDescr::NoArg(Box::new(|| Flag::Help))),
            (
                "version",
                args::FlagDescr::NoArg(Box::new(|| Flag::Version)),
            ),
            ("dump-ir", args::FlagDescr::NoArg(Box::new(|| Flag::DumpIr))),
            (
                "dump-instr",
                args::FlagDescr::NoArg(Box::new(|| Flag::DumpInstr)),
            ),
            (
                "exec-step-trace",
                args::FlagDescr::NoArg(Box::new(|| Flag::ExecStepTrace)),
            ),
            (
                "step-address",
                args::FlagDescr::Arg(Box::new(|s| {
                    if let Ok(p) = u64::from_str_radix(&s, 16) {
                        Ok(Flag::StepAddress(p))
                    } else {
                        Err(format!("step address '{}' is invalid", s))
                    }
                })),
            ),
            (
                "frontend",
                args::FlagDescr::Arg(Box::new(|s| {
                    if s == "brigadier" {
                        Ok(Flag::Frontend(Frontend::General))
                    } else if s == "major" {
                        Ok(Flag::Frontend(Frontend::Major))
                    } else if s == "corporal" {
                        Ok(Flag::Frontend(Frontend::Corporal))
                    } else {
                        Err(format!("unknown frontend {}", s))
                    }
                })),
            ),
        ],
    };
    let (flags, args) = args::args(options)?;

    let help_req = flags.contains(&Flag::Help);
    let ver_req = flags.contains(&Flag::Version);

    if help_req {
        help();
        return Ok(());
    }
    if ver_req {
        version();
        return Ok(());
    }

    let dump_ir = flags.contains(&Flag::DumpIr);
    let dump_instr = flags.contains(&Flag::DumpInstr);
    let exec_step_trace = flags.contains(&Flag::ExecStepTrace);
    let step_address = flags
        .iter()
        .filter_map(|f| match f {
            Flag::StepAddress(f) => Some(*f),
            _ => None,
        })
        .collect::<Vec<_>>();
    let frontend = flags
        .iter()
        .filter_map(|f| match f {
            Flag::Frontend(f) => Some(*f),
            _ => None,
        })
        .last()
        .unwrap_or(Frontend::General);

    let params = SioParams {
        dump_ir,
        dump_instr,
        exec_step_trace,
        step_address,
        frontend,
    };
    let src = "
        (define (fact acc x)
            (if (<= x 0)
                acc
                (fact (* acc x) (- x 1))))
        (define x
            (+ x 100))
        (define main
          	(fact 1 5))
    	";
    let mut brigadier_env = create_brigadier_env();
    let mut garrison = Garrison::new(src.to_string(), "brigadier".to_string(), brigadier_env);

    let mut major_env = create_major_env();
    let major = Major::new(src.to_string(),"major".to_string(), major_env).expect("reason");
    garrison.add_major(major);

    let mut corporal_env = create_corporal_env();
    let corporal= Corporal::new(src.to_string(),"corporal".to_string(), corporal_env).expect("reason");
    garrison.add_corporal(corporal);

    loop {
        garrison.march();
    }

    Ok(())
}
