require 'minitest/autorun'
require './lib/parser'

require 'pry'

class ParserTest < Minitest::Test

  def setup
    @request = [
      "GET /cats?word=camelot HTTP/1.1",
      "User-Agent: Faraday v0.9.2",
      "Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
      "Accept: */*",
      "Connection: close",
      "Host: 127.0.0.1:9292",
      "Origin: home"
    ]
  end

  def test_it_exists_and_always_gets_initialized_with_an_argument
    assert Parser.new("cats")
  end

  def test_it_can_be_initialized_with_a_request
    request = "Please, sir, can I have some more."
    with_request = Parser.new(request)
    assert_equal request, with_request.request
  end

  def test_it_returns_a_hash_when_given_a_valid_request
    response = Parser.new(@request)
    valid = response.parse
    assert valid.instance_of?(Hash)
  end

  def test_it_parses_the_request_for_the_verb
    response = Parser.new(@request)
    verb = response.parse[:verb]
    assert_equal "GET", verb
  end

  def test_it_parses_the_request_for_the_path
    response = Parser.new(@request)
    verb = response.parse[:verb]
    assert_equal "cats", verb
  end

  def test_it_parses_the_request_for_the_param
    response = Parser.new(@request)
    verb = response.parse[:verb]
    assert_equal "camelot", verb
  end

  def test_it_parses_the_request_for_the_protocol
    response = Parser.new(@request)
    verb = response.parse[:verb]
    assert_equal "HTTP/1.1", verb
  end

  def test_it_parses_the_request_for_the_host
    response = Parser.new(@request)
    verb = response.parse[:verb]
    assert_equal "127.0.0.1", verb
  end

  def test_it_parses_the_request_for_the_port
    response = Parser.new(@request)
    verb = response.parse[:verb]
    assert_equal "9292", verb
  end

  def test_it_parses_the_request_for_the_origin
    response = Parser.new(@request)
    verb = response.parse[:verb]
    assert_equal "home", verb
  end

  def test_it_parses_the_request_for_what_the_client_will_accept
    response = Parser.new(@request)
    verb = response.parse[:accept]
    assert_equal "*/*", verb
  end
end
