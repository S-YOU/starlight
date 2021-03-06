use bytecode;
use clap::App;
use config::{set_global, Config};
use interp::Interp;
use interp_init;
use std::rc::Rc;
use value::Value;

pub struct Command {
    pub interp: Interp,
}

impl Command {
    pub fn new() -> Command {
        Command {
            interp: interp_init::init(),
        }
    }

    pub fn run(&mut self) {
        let yaml = load_yaml!("cli.yml");
        let matches = App::from_yaml(yaml).get_matches();
        let input = matches.value_of("INPUT").unwrap();

        let config = Config {
            debug_mode: matches.is_present("debug"),
            verbose_mode: matches.is_present("verbose"),
        };
        set_global(config);

        match bytecode::from_file(input) {
            Err(msg) => panic!("Error: invalid bytecode format: {}", msg),
            Ok(bc) => {
                debug!("execute module initialization function");
                let init = Rc::new(bc.main.to_value_code().clone());
                {
                    match self.interp.eval(None, init.clone(), Vec::new()) {
                        Ok(_) => {}
                        Err(msg) => panic!("# error: {}", msg),
                    };
                }

                debug!("get module");
                let m = match self.interp.get_module(&bc.module) {
                    None => panic!("# main: module not found {}", bc.module),
                    Some(m) => m,
                };

                debug!("execute 'main' function");
                {
                    match m.fields.get("main") {
                        Some(Value::CompiledCode(code)) => {
                            match self.interp.eval(None, code.clone(), Vec::new()) {
                                Ok(value) => debug!("# main => {:?}", value),
                                Err(msg) => println!("# error: {}", msg),
                            }
                        }
                        Some(value) => panic!("# main/0 {:?} must be a function", value),
                        None => debug!("# main() not found"),
                    }
                }
            }
        }
    }
}

pub fn run() {
    let mut cmd = Command::new();
    cmd.run()
}
