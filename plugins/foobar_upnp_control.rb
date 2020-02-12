require 'concurrent'
require 'rest-client'
require 'yaml'
require 'json'

class FoobarController
  @foobar_host = nil
  @song_request_playlist_id = nil
  @current_song_task = nil
  Concurrent::TimerTask.new do
    begin
      current_info = RestClient.get "#{@foobar_host}/api/player"
      p current_info.body
    rescue => e
      puts e
    end
  end

  def initialize(debug = false)
    @current_song_task = Concurrent::TimerTask.new do
      begin
        current_info = RestClient.get "#{@foobar_host}/api/player"
        song_index = JSON.parse(current_info.body).first[1].first[1]['index']
        remove_previous_song if song_index > 0
      rescue => e
        puts e
      end
    end

    @current_song_task.execution_interval = 5
    @current_song_task.timeout_interval = 10
    if File.exist?("#{Dir.pwd}/config/foobar.yml")
      temp_yaml_file = YAML.load_file("#{Dir.pwd}/config/foobar.yml")
      @foobar_host = 'http://' + temp_yaml_file['host'].to_s + ':' + temp_yaml_file['port'].to_s
    else
      raise 'No config file found'
    end
    
    begin
      if get_songrequest_playlist.nil?
        RestClient.post "#{@foobar_host}/api/playlists/add", {:title => 'Song Requests'}.to_json
        @song_request_playlist_id = get_songrequest_playlist
      else
        @song_request_playlist_id = get_songrequest_playlist
      end
    rescue => e
      raise "Unable to connect to Foobar via REST api"
    end

    puts "song request playlist id is #{@song_request_playlist_id}"
    @current_song_task.execute
  end
  
  def get_songrequest_playlist
    begin
      current_playlists = JSON.parse(RestClient.get "#{@foobar_host}/api/playlists")
      song_request_playlist = current_playlists['playlists'].select do |playlist|
        playlist['title'] == 'Song Requests'
      end.first
      
      if song_request_playlist.nil?
        return nil
      else
        return song_request_playlist['id']
      end
    rescue
      raise "Unable to retrieve playlist info"
    end
  end
  
  def add_song_to_queue(url)
    begin
      request_template = {
        :items => ["#{url}"]
      }.to_json
      RestClient.post "#{@foobar_host}/api/playlists/#{@song_request_playlist_id}/items/add", request_template
    rescue => e
      puts e
    end
  end
  
  def remove_previous_song
    begin
      request_template = {
        :items => [0]
      }.to_json
      RestClient.post "#{@foobar_host}/api/playlists/#{@song_request_playlist_id}/items/remove", request_template
    rescue => e
      puts e
    end  
  end
end

