require 'minitest/autorun'
require 'faraday'
require './lib/yeah_you_know_me'

require 'pry'

class YeahYouKnowMeTest < Minitest::Test
  `tmux send -t goo_server goo ENTER` && `sleep 1`

  def setup
    @conn = Faraday.new(:url => 'http://127.0.0.1:9292') do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter Faraday.default_adapter
    end
  end

  def test_it_listens_on_port_9292
    response = @conn.get('/')
    assert response.body.include?('9292')
  end

  def test_it_responds_to_http_requests
    get = @conn.get('/')
    assert get.body
    assert_equal 200, get.status
  end

  def test_it_contains_hello_world_in_response_body
    response = @conn.get('/hello')
    assert response.body.include?('Hello, World!')
  end

  def test_it_iterates_counter_each_time_page_is_requested
    response = @conn.get('/hello')
    counter = response.body.scan(/\((.*)\)/).dig(0,0).to_i
    4.times { @conn.get('/hello') }
    new_response = @conn.get('/hello')
    counter_plus_5 = new_response.body.scan(/\((.*)\)/).dig(0,0).to_i
    difference = counter_plus_5 - counter
    assert_equal 5, difference
  end

  def test_it_can_respond_to_a_request_for_the_root_path_with_the_diagnostic_information
    response = @conn.get('/')
    assert response.body.include?("Home Page")
    assert response.body.include?('Verb:')
    assert response.body.include?('Path:')
    assert response.body.include?('Protocol:')
    assert response.body.include?('Host:')
    assert response.body.include?('Port:')
    assert response.body.include?('Origin:')
    assert response.body.include?('Accept:')
    assert response.body.include?('Content_length:')
  end

  def test_it_can_respond_with_hello_world_and_counter_when_hello_path_requested
    hello = @conn.get('/hello')
    assert hello.body.include?('Hello, World!')
    root = @conn.get('/')
    refute root.body.include?('Hello, World!')
  end

  def test_it_shows_current_year_month_day_time_information_when_datetime_path_requested
    pretty_date = @conn.get('/datetime')
    current_month = Time.new.strftime('%b')
    current_day = Time.new.strftime('%A')
    current_year = Time.new.strftime('%Y')
    current_twelve_hour_period = Time.new.strftime('%p')
    assert pretty_date.body.include?(current_month)
    assert pretty_date.body.include?(current_day)
    assert pretty_date.body.include?(current_year)
    assert pretty_date.body.include?(current_twelve_hour_period)
  end

  def test_it_shows_intentionally_blank_page_when_any_non_specified_path_is_requested
    response = @conn.get('/flibbertigibbet')
    blank_on_purpose = "This page intentionally left blank."
    assert response.body.include?(blank_on_purpose)
  end

  def test_it_shows_total_number_of_requests_and_kills_server_when_shutdown_path_requested
    # Admit it, this is kinda bitchin'
    close_er_up = @conn.get('/shutdown')
    assert close_er_up.body.include?('Total Requests')
    begin
      @conn.get('/')
     rescue Faraday::Error::ConnectionFailed
      puts "\nThe server was shutdown."
      puts ""
    end
    `tmux send -t goo_server goo ENTER` && `sleep 1`
  end

  def test_it_can_print_a_response_to_the_page_when_word_search_path_requested
    word_search = @conn.get('/word_search')
    assert word_search.body.include?('known word')
  end

  def test_it_properly_parses_the_path_even_when_params_are_included
    response = @conn.get('/word_search?word=fragment')
    path = "Path: word_search"
    assert response.body.include?(path)
  end

  def test_it_properly_parses_the_params_when_included
    response = @conn.get('/word_search?word=fragmen')
    word_stub = "Param: fragmen"
    assert response.body.include?(word_stub)
  end

  def test_it_returns_that_it_is_not_a_word_when_word_stub_is_not_in_dictionary
    response = @conn.get('/word_search?word=asdfasd')
    not_a_word = "asdfasd is not a known word"
    assert response.body.include?(not_a_word)
  end

  def test_it_returns_that_it_is_a_valid_word_when_word_stub_is_present_in_dictionary
    response = @conn.get('/word_search?word=dictionary')
    is_a_word = "dictionary is a known word"
    assert response.body.include?(is_a_word)
  end

  def test_it_properly_handles_uppercase_characters
    response = @conn.get('/word_search?word=DICTIONARY')
    is_a_word = "dictionary is a known word"
    assert response.body.include?(is_a_word)
  end

  def test_it_can_get_game
    response = @conn.get('/game')
    assert response.body.include?('Guesses Made:')
  end

  def test_it_can_post_to_start_game
    response = @conn.post('/start_game')
    assert response.body.include?('Good luck!')
  end

  def test_it_can_post_to_game_with_a_guess
    skip
    my_guess = 99
    response = @conn.post('/game', { guess: my_guess })
    assert_equal 302, response.status 
    game = @conn.get('/game')
    assert game.body.include?("Last Guess: #{my_guess}")
  end

  def test_posting_to_start_game_causes_a_get_request_to_game
    skip
    start = @conn.post('/start_game')
  end

  def test_it_can_post_to_game_to_make_guesses
    skip
    respose = @conn.post('/game')
    # not sure what comes next
  end

  def test_posting_to_game_to_make_a_guess_causes_a_get_request_to_game
    skip
    guess = @conn.post('/game')
    # not sure how to test
  end

  def test_it_can_show_a_guess_is_too_low
    skip
    # your guess was too low
  end

  def test_it_can_show_a_guess_is_too_high
    skip
    # your guess was too high
  end

  def test_it_can_show_a_guess_is_correct
    skip
    # goldilocks, your guess was just right
  end
end
