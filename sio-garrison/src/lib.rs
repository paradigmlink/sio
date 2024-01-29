struct Garrison {}

impl Garrison {
    pub fn new(config: &str) -> Self {
        Self {}
    }
    pub fn init(&self) {
    }
    pub fn step(&self) {
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let garrison = Garrison::new("brigadier");
        garrison.init();
        garrison.step();
        assert_eq!(4, 4);
    }
}
