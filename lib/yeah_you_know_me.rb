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
    response = Response.new(body, request)
    response.full_response
  end

  def parse(request)
    parser = Parser.new(request)
    diagnostic = parser.parse
  end

  def find_path(request)
    parser = Parser.new(request)
    parser.find_path
  end

  def get_param(request)
    parser = Parser.new(request)
    parser.get_param
  end

  def route(path, body, counter, request)
    case path
    when 'hello'
      hello(body, counter)
    when 'datetime'
      datetime(body)
    when 'shutdown'
      shutdown(body, counter)
    when 'word_search'
      word_search(body, request)
    end
  end

  def hello(body, counter)
    body << "\nHello, World! (#{counter})"
  end

  def datetime(body)
    body << Time.now.strftime('%l:%M%p on %A, %b %d, %Y ')
  end

  def shutdown(body, counter)
    body << "Total Requests: #{counter}"
  end

  def word_search(body, request)
    word = get_param(request)
    word.start_with?("Nary a pair") ? nil : word

    body << "#{word} is not a known word" if ! in_dictionary?(word)
    body << "#{word} is a known word" if in_dictionary?(word)
  end

  def in_dictionary?(word)
    whole_dictionary.include?(word)
  end

  def whole_dictionary
    @loaded_dictionary ||= File.read('/usr/share/dict/words').split("\n")
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
