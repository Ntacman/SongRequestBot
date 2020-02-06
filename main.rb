require './lib/foobar_upnp_control.rb'
require './lib/commandlistener.rb'
require 'readline'

@foobar = FoobarController.new

def process_command(command = '')
  case
  when command[0..2].downcase == '!sr'
    @foobar.add_song_to_queue(command.split(' ')[1])
  else
    puts "Unknown command #{command}"
  end
end

Bot.new('irc.chat.twitch.tv', 6667)

while buf = Readline.readline("> ", true)
  process_command(buf)
end
