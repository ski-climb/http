require_relative './parser'
require 'pry'

class Response
  attr_accessor :page
  attr_reader :body,
              :request

  def initialize(body, request)
    @body = body
    @request = request
  end

  def full_response
    assemble_page
    return headers + page
  end

  def headers
    [
      "http/1.1 200 OK",
      "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
      "server: ruby",
      "content-type: text/html; charset=iso-8859-1",
      "content-length: #{page.length}\r\n\r\n"
    ].join("\r\n")
  end

  def assemble_page
    show_diagnostics
    self.page = "\n<html><head></head><body>#{body}</body></html>"
  end

  def show_diagnostics
    diagnostic = Parser.new(request).parse
    body << "<pre>"
    diagnostic.each do |k, v|
      body << "#{k.capitalize}: #{v}\n"
    end
    body << "</pre>"
  end

  def hello(counter)
    body << "\nHello, World! (#{counter})"
  end

  def datetime
    body << Time.now.strftime('%l:%M%p on %A, %b %d, %Y ') #=> e.g. 3:52PM on Wednesday, Oct 26, 2016
  end

  def shutdown(counter)
    body << "Total Requests: #{counter}"
  end

  def root
    body << "Home Page"
  end

  def blank
    body << "This page intentionally left blank."
  end

  def get_game
    body << "Guesses Made:"
  end

  def post_start_game
    body << "Good luck!"
  end

  def post_game(request_body)
    last_guess = request_body.split('=').last
    body << "Last Guess: #{last_guess}"
  end

  def word_search
    word = Parser.new(request).get_param
    word.start_with?("Nary a pair") ? nil : word
    return body << "#{word} is not a known word" if ! in_dictionary?(word)
    return body << "#{word} is a known word" if in_dictionary?(word)
  end

  def in_dictionary?(word)
    whole_dictionary.include?(word)
  end

  def whole_dictionary
    @loaded_dictionary ||= File.read('/usr/share/dict/words').split("\n")
  end

end
