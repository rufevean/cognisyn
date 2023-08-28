use clap::Parser;
use question::{Answer, Question};
use reqwest::Client;
use serde_json::json;
use serde_json::Value;
use std::{
    env,
    process::{exit, Command},
};
#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    #[clap(short, long)]
    prompt: Vec<String>,
    #[clap(short, long)]
    force: bool,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // ... (rest of the main function remains unchanged)
    let api_key = env::var("OPENAI_API_KEY").unwrap_or_else(|_| {
        eprintln!("API_KEY is not set");
        exit(1)
    });

    let args = Args::parse();
    let prompt = args.prompt;
    let client = Client::new();
    let api_base =
        env::var("OPENAI_API_BASE").unwrap_or_else(|_| String::from("https://api.openai.com/v1"));

    let api_addr = format!("{}/completions", api_base);

    let response = client
        .post(api_addr)
        .json(&json!({
            "top_p": 1,
            "stop": "```",
            "temperature": 0,
            "suffix": "\n```",
            "max_tokens": 1000,
            "presence_penalty": 0,
            "frequency_penalty": 0,
            "model": "text-davinci-003",
            "prompt": build_prompt(&prompt.join(" ")),
        }))
        .header("Authorization", format!("Bearer {}", api_key))
        .send()
        .await
        .unwrap();

    // Extract and print the status code
    let response_json: Value = response.json().await?;
    let mut result = String::new();

    if let Some(choices) = response_json
        .get("choices")
        .and_then(|choices| choices.as_array())
    {
        if let Some(choice) = choices.first() {
            if let Some(text) = choice.get("text").and_then(|text| text.as_str()) {
                result = text.to_string();
            }
        }
    }
    let should_run = if args.force {
        true
    } else {
        Question::new(">> Run the generated program? [Y/n]".to_string().as_str())
            .yes_no()
            .until_acceptable()
            .default(Answer::YES)
            .ask()
            .expect("Couldn't ask question.")
            == Answer::YES
    };

    if should_run {
        let output = Command::new("bash")
            .arg("-c")
            .arg(result.as_str())
            .output()
            .unwrap_or_else(|e| {
                std::process::exit(1);
            });

        println!("{}", String::from_utf8_lossy(&output.stdout));
    }
    Ok(())
}

fn build_prompt(prompt: &str) -> String {
    format!("{prompt}:\n```bash\n#!/bin/bash\n", prompt = prompt)
}

