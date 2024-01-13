pub enum FlagDescr<T> {
    NoArg(Box<dyn Fn() -> T>),
    #[allow(unused)]
    ArgOpt(Box<dyn Fn(Option<String>) -> Result<T, String>>),
    #[allow(unused)]
    Arg(Box<dyn Fn(String) -> Result<T, String>>),
}

pub type ShortTable<T> = [(char, FlagDescr<T>)];
pub type LongTable<T> = [(&'static str, FlagDescr<T>)];

pub struct ArgOptions<'a, T> {
    pub short: &'a ShortTable<T>,
    pub long: &'a LongTable<T>,
}

pub fn args<'a, T>(options: ArgOptions<'a, T>) -> Result<(Vec<T>, Vec<String>), String> {
    let mut it = std::env::args().skip(1);

    let mut flags = Vec::new();
    let mut no_opts = Vec::new();

    while let Some(first) = it.next() {
        if first == "--" {
            no_opts.extend(it);
            break;
        } else if let Some(r) = first.strip_prefix("--") {
            let mut found = None;
            for (opt_s, fd) in options.long {
                if let Some(l) = r.strip_prefix(opt_s) {
                    found = Some((fd, l));
                    break;
                }
            }
            let Some((fd, rem)) = found else {
                return Err(format!("unknown long option '{}'", r));
            };

            let flag = match fd {
                FlagDescr::NoArg(f) => Ok(f()),
                FlagDescr::ArgOpt(f) => {
                    if let Some(opt_value) = rem.strip_prefix("=") {
                        f(Some(opt_value.to_string()))
                    } else {
                        f(None)
                    }
                }
                FlagDescr::Arg(f) => {
                    if let Some(opt_value) = rem.strip_prefix("=") {
                        f(opt_value.to_string())
                    } else {
                        let Some(value) = it.next() else {
                            return Err(format!("option '{}' missing parameter", r));
                        };
                        f(value)
                    }
                }
            };
            match flag {
                Err(e) => return Err(e),
                Ok(flag) => flags.push(flag),
            }
        } else if let Some(r) = first.strip_prefix("-") {
            let mut chars = r.chars();
            let mut found = None;
            let Some(c) = chars.next() else {
                return Err(format!("short option missing a character"));
            };
            let None = chars.next() else {
                return Err(format!("short option"));
            };
            for (opt_c, fd) in options.short {
                if c == *opt_c {
                    found = Some(fd);
                    break;
                }
            }
            let Some(fd) = found else {
                return Err(format!("unknown short option '{}'", c));
            };
            let flag = match fd {
                FlagDescr::NoArg(f) => Ok(f()),
                FlagDescr::ArgOpt(_f) => {
                    return Err(format!("option '{}' cannot be arg-opt", r));
                }
                FlagDescr::Arg(f) => {
                    let Some(value) = it.next() else {
                        return Err(format!("option '{}' missing parameter", r));
                    };
                    f(value)
                }
            };
            match flag {
                Err(e) => return Err(e),
                Ok(flag) => flags.push(flag),
            }
        } else {
            no_opts.push(first)
        }
    }
    Ok((flags, no_opts))
}
