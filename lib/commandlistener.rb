require 'summer'
require './lib/foobar_upnp_control.rb'

$foobar = FoobarController.new

class Bot < Summer::Connection
  def did_start_up
    response('CAP REQ :twitch.tv/membership')
  end

  def channel_message(sender, channel, message)
    puts "saw message from: #{sender[:nick]}, message was: #{message}"
    $foobar.add_song_to_queue(message.split(' ')[1]) if message[0..2].downcase == '!sr'
  end
  
  def join_event(sender, channel)
  end
end
