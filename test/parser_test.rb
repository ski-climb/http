require 'minitest/autorun'
require './lib/parser'

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
    assert Parser.new(@request)
  end

  def test_it_can_be_initialized_with_a_request
    with_request = Parser.new(@request)
    assert_equal @request, with_request.request
  end

  def test_it_returns_the_hashyized_hash_with_key_accept
    parser = Parser.new(@request)
    parsed_hash = parser.from_request
    assert parsed_hash.has_key?('Accept')
  end

  def test_it_returns_the_hashyized_hash_with_key_host
    parser = Parser.new(@request)
    parsed_hash = parser.from_request
    assert parsed_hash.has_key?('Host')
  end

  def test_it_returns_the_hashyized_hash_with_key_origin
    parser = Parser.new(@request)
    parsed_hash = parser.from_request
    assert parsed_hash.has_key?('Origin')
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
    path = response.parse[:path]
    assert_equal "cats", path
  end

  def test_it_parses_the_request_for_the_param
    response = Parser.new(@request)
    param = response.parse[:param]
    assert_equal "camelot", param
  end

  def test_it_parses_the_request_for_the_param_when_no_param_exists
    request = [
      "GET /dogs HTTP/1.1",
      "User-Agent: Faraday v0.9.2",
      "Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
      "Accept: */*",
      "Connection: close",
      "Host: 127.0.0.1:9292",
      "Origin: home"
    ]
    response = Parser.new(request)
    param = response.parse[:param]
    assert_equal "Nary a pair of rams to be found.", param
  end

  def test_it_parses_the_request_for_the_protocol
    response = Parser.new(@request)
    protocol = response.parse[:protocol]
    assert_equal "HTTP/1.1", protocol
  end

  def test_it_parses_the_request_for_the_host
    response = Parser.new(@request)
    host = response.parse[:host]
    assert_equal "127.0.0.1", host
  end

  def test_it_parses_the_request_for_the_port
    response = Parser.new(@request)
    port = response.parse[:port]
    assert_equal "9292", port
  end

  def test_it_parses_the_request_for_the_origin
    response = Parser.new(@request)
    origin = response.parse[:origin]
    assert_equal "home", origin
  end

  def test_it_parses_the_request_for_the_origin_when_no_origin_provided
    request = [
      "GET /cats?word=camelot HTTP/1.1",
      "User-Agent: Faraday v0.9.2",
      "Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
      "Accept: */*",
      "Connection: close",
      "Host: 127.0.0.1:9292"
    ]
    response = Parser.new(request)
    origin = response.parse[:origin]
    assert_equal "Are you too good for your home?", origin
  end

  def test_it_parses_the_request_for_what_the_client_will_accept
    response = Parser.new(@request)
    accept = response.parse[:accept]
    assert_equal "*/*", accept
  end
end
