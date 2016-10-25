require 'minitest/autorun'
require 'faraday'
require './lib/yeah_you_know_me'

require 'pry'

class YeahYouKnowMeTest < Minitest::Test


  def setup
    # `tmux new -s goo_server` && `tmux detach` && `tmux send -t goo_server goo ENTER`
    @conn = Faraday.new(:url => 'http://127.0.0.1:9292') do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter Faraday.default_adapter
    end
  end

  # def teardown
  #   @conn.get('/shutdown')
  # end

  def test_it_listens_on_port_9292
    response = @conn.get('/')
    assert response.body.include?('9292')
  end

  def test_it_responds_to_http_requests
    get = @conn.get('/')
    assert get.body
    assert_equal 200, get.status
    post = @conn.post('/')
    assert post.body
    assert_equal 200, post.status
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
    assert response.body.include?('Verb:')
    assert response.body.include?('Path:')
    assert response.body.include?('Protocol:')
    assert response.body.include?('Host:')
    assert response.body.include?('Port:')
    assert response.body.include?('Origin:')
    assert response.body.include?('Accept:')
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

  # need a way to start the server and shut it down for each test before this one will work
  #
  # def test_it_shows_total_number_of_requests_and_kills_server_when_shutdown_path_requested
  #   close_er_up = @conn.get('/shutdown')
  #   assert close_er_up.body.include?('Total Requests')
  #   fails = @conn.get('/')
  #   assert_equal 100, fails.status
  # end

end
