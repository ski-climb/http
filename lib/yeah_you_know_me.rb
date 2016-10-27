require 'socket'
require 'pry'
require_relative './parser'
require_relative './response'

class YeahYouKnowMe
  attr_accessor :request,
                :socket,
                :body,
                :server,
                :path
  attr_reader :counter

  def initialize
    self.server = TCPServer.new(9292)
  end

  def be_a_server
    @counter = 0
    loop do
      listen
      route_path
      respond

      @counter += 1
      break if path == 'shutdown'
      socket.close
    end
  end

  def listen
    self.body = ""
    self.socket = server.accept
    self.request = get_request(socket)
  end

  def route_path
    self.path = find_path(request)
    route(path, body, counter, request)
  end

  def respond
    socket.puts full_response(body, request)
  end

  def get_request(socket)
    request = []
    while line = socket.gets and !line.chomp.empty?
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

end
