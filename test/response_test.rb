require 'minitest/autorun'
require './lib/response'

require 'pry'

class ResponseTest < Minitest::Test

  def setup
    @body = ""
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
    assert Response.new(@body, @request)
  end

  def test_it_has_a_body
    body = "cats"
    response = Response.new(body, @request)
    assert_equal body, response.body
  end

  def test_it_has_a_request
    request = [
      "GET /cats?word=camelot HTTP/1.1",
      "User-Agent: Faraday v0.9.2",
      "Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
      "Accept: */*",
      "Connection: close",
      "Host: 127.0.0.1:9292",
      "Origin: home"
    ]
    response = Response.new(@body, request)
    assert_equal request, response.request
  end

  def test_it_returns_a_well_formatted_body
    response = Response.new(@body, @request)
    assembled_page = response.assemble_page.strip
    assert assembled_page.start_with?('<html><head></head><body>')
    assert assembled_page.end_with?('</body></html>')
  end

  def test_it_returns_headers
    response = Response.new(@body, @request)
    response.assemble_page
    header_info = "http/1.1 200 OK"
    assert response.headers.include?(header_info)
  end

  def test_full_response_includes_headers
    response = Response.new(@body, @request)
    header_info = "server: ruby"
    assert response.full_response.include?(header_info)
  end

  def test_full_response_includes_body
    body = "cats"
    response = Response.new(body, @request)
    assert response.full_response.include?(body)
  end

  def test_full_response_includes_diagnostics
    response = Response.new(@body, @request)
    diagnostic_info = "Port: 9292"
    assert response.full_response.include?(diagnostic_info)
  end

  def test_it_returns_home_page_when_root_is_requested
    request = "GET / HTTP/1.1"
    response = Response.new(@body, request)
    assert response.root.include?('Home Page')
  end

  def test_it_returns_intentionally_blank_page_when_other_page_requested
    request = "GET /flibbertigibbet HTTP/1.1"
    response = Response.new(@body, request)
    assert response.blank.include?('This page intentionally left blank.')
  end

  def test_it_returns_hello_world_when_get_hello_requested
    request = "GET /hello HTTP/1.1"
    response = Response.new(@body, request)
    assert response.hello(4).include?('Hello, World!')
  end

  def test_it_returns_date_and_time_information_when_get_datetime_requested
    request = "GET /datetime HTTP/1.1"
    response = Response.new(@body, request)
    day = Time.now.strftime('%A')
    month = Time.now.strftime('%b')
    assert response.datetime.include?(day)
    assert response.datetime.include?(month)
  end

  def test_it_returns_final_count_when_get_shutdown_requested
    request = "GET /shutdown HTTP/1.1"
    response = Response.new(@body, request)
    final_count = 4
    assert response.shutdown(final_count).include?("Total Requests: #{final_count}")
  end

  def test_it_returns_that_a_word_is_in_the_dictionary
    word = "diligence"
    @request[0] = "GET /word_search?word=#{word} HTTP/1.1"
    response = Response.new(@body, @request)
    assert response.word_search.include?("#{word} is a known word")
  end

  def test_it_returns_that_a_word_is_not_in_the_dictionary
    word = "flibbertigibbetly"
    @request[0] = "GET /word_search?word=#{word} HTTP/1.1"
    response = Response.new(@body, @request)
    assert response.word_search.include?("#{word} is not a known word")
  end

  def test_it_returns_a_game_status_page_when_get_game_requested
    @request[0] = "GET /game HTTP/1.1"
    response = Response.new(@body, @request)
    assert response.get_game.include?('Guesses Made:')
  end
end
