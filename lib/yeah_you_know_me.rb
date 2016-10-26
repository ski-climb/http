require 'socket'
require 'pry'
require_relative './parser'

class YeahYouKnowMe
  def listen(client)
    request = []
    while line = client.gets and !line.chomp.empty?
      request << line.chomp
    end
    return request
  end

  def assemble_page(body)
    "<html><head></head><body>#{body}</body></html>"
  end

  def assemble_headers(page)
    headers = [ "http/1.1 200 OK",
                "date: #{Time.now.strftime('%1, %e %b %Y %H:%M:%S %z')}",
    "server: ruby",
      "content-type: text/html; charset=iso-8859-1",
      "content-length: #{page.length}\r\n\r\n"].join("\r\n")
  end

  def show_diagnostics(request, body)
    diagnostic = parse(request)
    body << "<pre>"
    diagnostic.each do |k, v|
      body << "#{k.capitalize}: #{v}\n"
    end
    body << "</pre>"
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

      show_diagnostics(request, body)
      page = assemble_page(body)

      client.puts assemble_headers(page)
      client.puts page

      counter += 1
      client.close
      break if path == '/shutdown'
    end
  end

end
