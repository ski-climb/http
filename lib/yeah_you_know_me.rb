require 'socket'
require 'pry'
require_relative './parser'
require_relative './response'

class YeahYouKnowMe
  def listen(client)
    request = []
    while line = client.gets and !line.chomp.empty?
      request << line.chomp
    end
    return request
  end

  def full_response(body, request)
    Response.new(body, request).full_response
  end

  def find_path(request)
    Parser.new(request).find_path
  end

  def route(path, body, counter, request)
    case path
    when 'hello'
      Response.new(body, request).hello(counter)
    when 'datetime'
      Response.new(body, request).datetime
    when 'shutdown'
      Response.new(body, request).shutdown(counter)
    when 'word_search'
      Response.new(body, request).word_search
    end
  end

  def be_a_server
    server = TCPServer.new 9292 # Server bind to port 9292
    counter = 0
    loop do
      client = server.accept
      request = listen(client)
      body = ""
      path = find_path(request)

      route(path, body, counter, request)

      client.puts full_response(body, request)

      counter += 1
      client.close
      break if path == '/shutdown'
    end
  end
end
