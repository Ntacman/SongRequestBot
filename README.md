# SongRequestBot
Homemade Music Request Bot for Twitch.tv written in Ruby


# Set Up Instructions and Requirements
1. Have a functioning Ruby environment
2. Have the following gems installed:
```
summer(v1.0.0)
rest-client
```
3. Have Foobar2000 Set up with the following component
```
https://www.foobar2000.org/components/view/foo_beefweb
https://www.foobar2000.org/components/view/foo_youtube - If you want youtube support
```
4. Copy the example files in the `config` folder and remove the `.example` extensions
5. Open `foobar.yml` and set the `host` key to the IP of the computer running foobar2000*, and set the `port` key to the value configured in the foo_beefweb component configuration menu in foobar2000
6. Open `summer.yml` and configure the following options:
```
nick: 'your_bots_twitch_username_here'
use_ssl: false
server_password: 'your_oauth_token_with_oauth:_prefix'
channel: '#your_channel_here'
```
7. Run the command `ruby main.rb`, or if you're running newer versions of ruby and getting deprecation warnings, `ruby -W0 main.rb` to suppress them

## Notes
- We set SSL to false because there could be potential issues with the openssl library. Feel free to test it set to true for SSL.
- *The host key must be wrapped in quotes. For example, if your pc had an IP of 10.0.0.100, the host key would be `host: "10.0.0.100"`

# Other Issues
If you have any issues and I happen to be streaming, feel free to ask me at twitch.tv/itsdefinitelyfluff if I'm live, or raise an issue here.
