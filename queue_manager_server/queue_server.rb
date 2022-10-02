this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'queue_services_pb'
require 'pry'
require 'byebug'
require 'pry-byebug'

$song_queue

class QueueServer < Songrequest::Queue::Service
  # Fake a pre-existing queue with songs so we can write a smaller client example
  
  def initialize
    $song_queue = []
    5.times do |x|
      $song_queue << Songrequest::Song.new(
          requested_by: 'Fluff',
          song_url: 'www.youtube.com/watch?v=dQw4w9WgXcQ'
      )
    end
  end

  def list_songs(list_song_req, _unused_call)
    Songrequest::ListSongsResponse.new(songs: $song_queue)
  end

  def get_next_song(get_next_song_request, _unused_call)
    # BUG: For some reason when locally testing, shift wasn't
    # removing the first element as expected so this command
    # can be repeated infinitely.
    song = $song_queue.shift
    Songrequest::GetNextSongResponse.new(song: song)
  end

  def add_song(song, _unused_call)
    $song_queue << song
    Songrequest::ListSongsResponse.new(songs: $song_queue)
  end
end

def main
  s = GRPC::RpcServer.new
  s.add_http2_port('0.0.0.0:50051', :this_port_is_insecure)
  s.handle(QueueServer)
  s.run_till_terminated_or_interrupted([1, 'int', 'SIGTERM'])
end

main