require_relative './parser'

class Response
  attr_reader :body,
              :request

  def initialize(body, request)
    @body = body
    @request = request
  end

  def page
    show_diagnostics(request, body)
    "<html><head></head><body>#{body}</body></html>"
  end

  def headers
    [
      "http/1.1 200 OK",
      "date: #{Time.now.strftime('%1, %e %b %Y %H:%M:%S %z')}",
      "server: ruby",
      "content-type: text/html; charset=iso-8859-1",
      "content-length: #{page.length}\r\n\r\n"
    ].join("\r\n")
  end

  def full_response
    headers + "\n" + page
  end

  def show_diagnostics(request, body)
    parser = Parser.new(request)
    diagnostic = parser.parse
    body << "<pre>"
    diagnostic.each do |k, v|
      body << "#{k.capitalize}: #{v}\n"
    end
    body << "</pre>"
  end

end
