use std::env;

fn main() {
    let command = env::args().nth(1).unwrap_or_else(|| "help".to_string());

    match command.as_str() {
        "help" => print_help(),
        "deploy" => deploy(),
        other => {
            eprintln!("unknown xtask command: {other}");
            eprintln!("run `cargo run -p xtask -- help`");
            std::process::exit(2);
        },
    }
}

fn print_help() {
    println!("xtask commands:");
    println!("  deploy    run the project deployment workflow");
}

fn deploy() {
    println!("deploy workflow is not implemented yet");
}
