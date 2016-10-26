require 'minitest/autorun'
require './lib/response'

require 'pry'

class ResponseTest < Minitest::Test

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

  def test_it_exists
    assert Response.new("argument", "arg")
  end

  def test_it_has_a_body
    body = "cats"
    response = Response.new(body, @request)
    assert_equal body, response.body
  end

  def test_it_has_a_request
    body = "cats"
    request = [
      "GET /cats?word=camelot HTTP/1.1",
      "User-Agent: Faraday v0.9.2",
      "Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
      "Accept: */*",
      "Connection: close",
      "Host: 127.0.0.1:9292",
      "Origin: home"
    ]
    response = Response.new(body, request)
    assert_equal request, response.request
  end

  def test_it_returns_a_well_formatted_body
    body = "dogs"
    response = Response.new(body, @request)
    assembled_page = response.page
    assert assembled_page.start_with?('<html><head></head><body>')
    assert assembled_page.end_with?('</body></html>')
  end

  def test_it_returns_headers
    body = "cats"
    response = Response.new(body, @request)
    header_info = "http/1.1 200 OK"
    assert response.headers.include?(header_info)
  end

  def test_full_response_includes_headers
    body = "cats"
    response = Response.new(body, @request)
    header_info = "server: ruby"
    assert response.full_response.include?(header_info)
  end

  def test_full_response_includes_body
    body = "cats"
    response = Response.new(body, @request)
    assert response.full_response.include?(body)
  end

  def test_full_response_includes_diagnostics
    body = "cats"
    response = Response.new(body, @request)
    diagnostic_info = "Port: 9292"
    assert response.full_response.include?(diagnostic_info)
  end


end
