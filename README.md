# SongRequestBot
Homemade Music Request Bot for Twitch.tv written in Ruby


# Set Up Instructions and Requirements from pre-built release
1. Set up the config.toml file per the example
2. drop youtube-dl.exe or youtube-dl linux executable into the same directory as the app and config file
3. run `./SongRequestBot` in your terminal, or on windows open cmd and run `SongRequestBot.exe`

# Set Up Instructions and Requirements when building from Source
1. Set up the config.toml file per the example
2. drop youtube-dl.exe or youtube-dl linux executable into the same directory as the app and config file (If running a debug copy by `cargo run`, it should still look in the same directory where Cargo.toml resides)
3. `cargo run` to run in debug, or `cargo build --release` to build a release optimized build

# KNOWN BUGS - WINDOWS PLATFORM
Rust on Windows' `std::process::Command` library cannot handle unicode characters. Any video requested that contains unicode characters in the title will have those characters stripped. This appears to be a limitation that cannot be worked around. The Video will still play as normal in the web player. This does not affect linux.

# Other Issues
If you have any issues and I happen to be streaming, feel free to ask me at [http://twitch.tv/itsdefinitelyfluff](http://twitch.tv/itsdefinitelyfluff) if I'm live, or raise an issue here.
