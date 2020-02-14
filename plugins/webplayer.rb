require 'yaml'
require 'rest-client'
require 'json'

class WebPlayer
  def initialize
    @config = YAML.load_file('config/webplayer.yml')
    @youtube_dl_path = @config[:youtube_dl_path]
  end
  
  def add_to_queue(url = '')
    #RestClient.put "#{@config[:web_player_url]}api/add", {:name => "Song", :url => url}.to_json
    if url.include?('youtube.com')
      processed_url = process_youtube(url)
      RestClient.put "#{@config[:web_player_url]}api/add", processed_url.to_json
      return processed_url
    else
      return
    end
  end
  
  def get_queue
    playlist = JSON.parse(RestClient.get("#{@config[:web_player_url]}api/playlist").body)
  end
  
  private
  def process_youtube(url = '')
    audio_url = `#{@youtube_dl_path} -f bestaudio -g #{url}`
    title = `#{@youtube_dl_path} -s --get-title #{url}`
    title.gsub(/\n/, "") 
    audio_url.gsub(/\n/, "")
    {:name => title, :url => audio_url}
  end
end
