require 'socket'
require 'pry'

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
    diagnostic = { verb: get_verb(request),
                   path: find_path(request),
                   protocol: get_protocol(request),
                   host: get_host(request),
                   port: get_port(request),
                   origin: get_origin(request),
                   accept: get_accept(request),
    }
  end

  def get_verb(request)
    request.first.split[0]
  end

  def get_protocol(request)
    request.first.split[2]
  end

  def get_host(request)
    request.find { |s| s.start_with?('Host:') }.scan(/(\S*):\d/).dig(0,0)
  end

  def get_port(request)
    request.find { |s| s.start_with?('Host:') }.scan(/:(\d*)\z/).dig(0,0)
  end

  def get_origin(request)
    return request.find { |s| s.start_with?('Origin:') }.scan(/:\s(.*)/).dig(0,0) if origin?(request)
    "Are you too good for your home?"
  end

  def origin?(request)
    request.join.downcase.include?('origin')
  end

  def get_accept(request)
    request.find { |s| s.start_with?('Accept:') }.scan(/:\s(.*)/).dig(0,0)
  end

  def find_path(request)
    request.first.split[1]
  end

  def route(path, body, counter)
    case path
    when '/hello'
      hello(body, counter)
    when '/datetime'
      datetime(body)
    when '/shutdown'
      shutdown(body, counter)
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

  def be_a_server
    server = TCPServer.new 9292 # Server bind to port 9292
    counter = 0
    loop do
      client = server.accept
      request = listen(client)
      body = ""
      path = find_path(request)

      route(path, body, counter)

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
