require 'socket'
require 'pry'
require_relative './parser'
require_relative './response'

class YeahYouKnowMe
  attr_accessor :request,
                :request_body,
                :socket,
                :body,
                :server,
                :verb_path
  attr_reader :counter,
              :body_content_length

  def initialize
    self.server = TCPServer.new(9292)
  end

  def be_a_server
    @counter = 0
    loop do
      listen
      route_path
      respond
      
      # binding.pry
      # you're right here.  you juuuust found the request_body (the guess=18)

      @counter += 1
      break if verb_path == 'GET-shutdown'
      socket.close
    end
  end

  def listen
    self.body = ""
    self.socket = server.accept
    self.request = get_request
    find_content_length
    get_request_body if body_content_present?
  end

  def route_path
    self.verb_path = find_verb_path
    route
  end

  def respond
    socket.puts full_response
  end

  def get_request
    request = []
    while line = socket.gets and !line.chomp.empty?
      request << line.chomp
    end
    return request
  end

  def get_request_body
    self.request_body = socket.read(body_content_length)
  end

  def full_response
    Response.new(body, request).full_response
  end

  def find_content_length
    @body_content_length = Parser.new(request).get_content_length
  end

  def body_content_present?
    body_content_length > 0
  end

  def find_path
    Parser.new(request).find_path
  end

  def find_verb
    Parser.new(request).find_verb
  end

  def find_verb_path
    verb = find_verb
    path = find_path
    "#{verb}-#{path}"
  end

  def route
    case verb_path
    when 'GET-hello'
      Response.new(body, request).hello(counter)
    when 'GET-datetime'
      Response.new(body, request).datetime
    when 'GET-shutdown'
      Response.new(body, request).shutdown(counter)
    when 'GET-word_search'
      Response.new(body, request).word_search
    when 'GET-root'
      Response.new(body, request).root
    when 'GET-game'
      Response.new(body, request).get_game
    when 'POST-start_game'
      Response.new(body, request).post_start_game
    when 'POST-game'
      Response.new(body, request).post_game(request_body)
    else
      Response.new(body, request).blank
    end
  end

end
