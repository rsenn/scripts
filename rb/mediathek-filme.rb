#!/usr/bin/env ruby

#require 'json/stream'
#stream = File.open('D:/Programs/MediathekView_11_2015.09.15/Einstellungen/.mediathek3/filme.json')
#obj = JSON::Stream::Parser.parse(stream)

#def post_init
#  @parser = JSON::Stream::Parser.new do
#    start_document { puts "start document" }
#    end_document   { puts "end document" }
#    start_object   { puts "start object" }
#    end_object     { puts "end object" }
#    start_array    { puts "start array" }
#    end_array      { puts "end array" }
#    key            {|k| puts "key: #{k}" }
#    value          {|v| puts "value: #{v}" }
#  end
#end

#def receive_data(data)
#  begin
#    @parser << data
#  rescue JSON::Stream::ParserError => e
#    close_connection
#  end
#end

#$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../..')
#$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../../lib')

file = ARGV[0] ? ARGV[0] : "C:/Users/roman/.mediathek3/filme.json" #D:/Programs/MediathekView_11_2015.09.15/Einstellungen/.mediathek3/filme.json"

require 'yajl'

unless file
  puts "\nUsage: ruby examples/from_file.rb benchmark/subjects/item.json\n\n"
  exit(0)
end

file_stream = File.new(file, 'r')

json = Yajl::Parser.parse(file_stream)
json.each do |hash|
  puts hash.inspect
end
file_stream.close