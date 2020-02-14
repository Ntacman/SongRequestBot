require 'summer'
require 'yaml'
require 'pathname'

class Bot < Summer::Connection

  def initialize(server, port = 6667, dry = false)
    @player = nil
    plugins = YAML.load_file('config/application.yml')
    player = plugins[:players].select { |x| x[:enabled] == true }.first
    require(player[:script])
    initialize_player(player[:name])
    super(server, port, dry)
  end

  def did_start_up
    response('CAP REQ :twitch.tv/membership')
  end

  def channel_message(sender, channel, message)
    puts "saw message from: #{sender[:nick]}, message was: #{message}"
    add_to_queue(message) if message[0..2] == '!sr' && message[3] == ' '
    get_queue if message[0..3] == '!srq'
  end
  
  def join_event(sender, channel)
  end

  private
  def initialize_player(player_name)
    ObjectSpace.each_object(Class) do |ob|
      if ob.to_s.downcase == player_name.to_s.downcase
        @player = ob.new
      end
    end
  end

  def add_to_queue(original_command)
    url = original_command.split(' ')[1]
    song = @player.add_to_queue(url)
    response("PRIVMSG #{config['channel']} :Added #{song[:name]}")
  end

  def get_queue
    items = @player.get_queue['items']
    response("PRIVMSG #{config['channel']} :Next song is #{items.first['name']}")
  end

  def config
    super
  end
end
