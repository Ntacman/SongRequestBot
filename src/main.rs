extern crate irc;

use irc::client::prelude::*;
use irc::client::Client;
use std::process::Command;
use ureq::json;
extern crate state;

static APIHOST: state::Storage<String> = state::Storage::new();

fn main() {
    let current_dir = std::env::current_dir();
    let cfg = if cfg!(target_os = "windows") {
      Config::load(format!("{}\\config.toml", current_dir.unwrap().to_string_lossy()))
    } else {
      Config::load(format!("{}/config.toml", current_dir.unwrap().to_string_lossy()))
    };

    let client = IrcClient::from_config(cfg.unwrap()).unwrap();
    client.identify().unwrap();
    client.send(irc::proto::command::Command::CAP(None, irc::proto::command::CapSubCommand::REQ, None, Some("twitch.tv/membership".to_owned())));
    set_api_url();
    println!("host is: {:?}", *APIHOST.get());
    client.for_each_incoming(|message| {
        let output = process_command(split_message(message.to_string()));
        if output != "" {
          client.send(irc::proto::command::Command::PRIVMSG("#itsdefinitelyfluff".to_string(), output));
        } else {
          ()
        }
    }).unwrap()
}

fn split_message(x: String) -> String {
  if x.contains("PRIVMSG") {
    x.splitn(3, ":").last().unwrap().trim_start_matches(":").to_string()
  } else {
    "".to_owned()
  }
}

fn process_command(x: String) -> String{
  if x == "" {return "".to_string()}
  
  if x.starts_with("!sr ") {
    println!("Song Request found");
    process_song_request(x)
  } else if x.starts_with("!srq") {
    println!("Next in Queue requested");
    get_next_in_queue()
  } else{
    "".to_string()
  }
}

fn process_song_request(x: String) -> String {
  let x_split = x.split_whitespace().last();
  if cfg!(target_os = "windows") {
    let output = Command::new("youtube-dl.exe")
            .args(&["--get-title", "-f", "best", "-g", &x_split.unwrap()])
            .output()
            .expect("Error running youtube-dl.exe");
    return add_to_queue(String::from_utf8_lossy(&output.stdout).to_string());
  } else {
    let output = Command::new("./youtube-dl")
            .args(&["--get-title", "-f", "best", "-g", &x_split.unwrap()])
            .output()
            .expect("Error running youtube-dl");
    return add_to_queue(String::from_utf8_lossy(&output.stdout).to_string());
  };
}


fn add_to_queue(x: String) -> String {
  let name = x.lines().nth(0).unwrap_or("empty");
  let url = x.lines().nth(1).unwrap_or("empty"); 
  let api_url = &format!("{}{}", *APIHOST.get(), "/api/add".to_string());
  let resp = ureq::put(api_url)
      .send_json(json!({
        "name": name,
        "url": url,
      }));
  if resp.ok() {
    format!("Successfully added song {}", name)
  } else {
    println!("{:?}", resp.into_string());
    "Unable to add requested song".to_string()
  }
}

fn get_next_in_queue() -> String {
  let api_url = &format!("{}{}", *APIHOST.get(), "/api/playlist".to_string());
  let resp = ureq::get(&api_url)
      .call();
  if resp.ok(){
    let json = resp.into_json().unwrap();
    let output = match json["items"][0]["name"].as_str() {
      None => "No song in queue.".to_string(),
      Some(value) => format!("Next song is: {}", value.to_string()),
    };
    return output
  } else {
    return "Unable to get queue".to_string()
  }
}

fn set_api_url() {
  let current_dir = std::env::current_dir();
  let cfg = if cfg!(target_os = "windows") {
    Config::load(format!("{}\\config.toml", current_dir.unwrap().to_string_lossy()))
  } else {
    Config::load(format!("{}/config.toml", current_dir.unwrap().to_string_lossy()))
  };
  let options = cfg.unwrap().options.unwrap();
  APIHOST.set(format!("{}:{}", options["api_host"].to_string(), options["api_port"].to_string()).to_string());
}