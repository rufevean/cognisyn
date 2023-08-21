use colored::Colorize;
use std::{env, io::Write, process::exit};

pub struct Config {
    pub api_key: String,
    pub api_base: String,
    pub shell: String,
}

impl Config {
    pub fn new() -> Self {
        let api_key = env::var("OPENAI_API_KEY").unwrap_or_else(|_| {
            println!("{}", "This program requires an OpenAI API key to run. Please set the OPENAI_API_KEY environment variable. https://github.com/m1guelpf/plz-cli#usage".red());
            exit(1);
        });
        let api_base = env::var("OPENAI_API_BASE")
            .unwrap_or_else(|_| String::from("https://api.openai.com/v1"));
        let shell = env::var("SHELL").unwrap_or_else(|_| String::new());

        Self {
            api_key,
            api_base,
            shell,
        }
    }
}
