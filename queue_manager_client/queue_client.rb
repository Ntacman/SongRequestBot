this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'queue_services_pb'
require 'pry'
require 'byebug'
require 'pry-byebug'
require 'readline'
require 'ffaker'

@stub = Songrequest::Queue::Stub.new('127.0.0.1:50051', :this_channel_is_insecure)
POTENTIAL_SONG_URLS = ['https://www.youtube.com/watch?v=dQw4w9WgXcQ', 'https://www.youtube.com/watch?v=5LR22ukkrVM', 'https://www.youtube.com/watch?v=zKoQ9IgJ8cc']
request = Songrequest::ListSongsRequest.new

def add_song
    song = Songrequest::Song.new(
        requested_by: FFaker::Internet.user_name,
        song_url: POTENTIAL_SONG_URLS.sample
    )
    @stub.add_song(song)
end

def list_songs
    request = Songrequest::ListSongsRequest.new
    @stub.list_songs(request)
end

def get_next_song
    request = Songrequest::GetNextSongRequest.new
    @stub.list_songs(request)
end

while buf = Readline.readline("> ", true)
    case
    when buf == 'add_song'
        response = add_song
        puts response.songs, response.songs.count
    when buf == 'list_songs'
        puts list_songs.inspect
    when buf == 'get_next_song'
        puts get_next_song.inspect
    when buf == 'pry'
        binding.pry
    else
        puts 'not a valid command'
    end 
end