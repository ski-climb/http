require 'minitest/autorun'
require 'faraday'
require './lib/yeah_you_know_me'

require 'pry'

class YeahYouKnowMeTest < Minitest::Test


  def setup
    `tmux send -t goo_server goo ENTER`
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
    response = @conn.get('/')
    assert response.body.include?('Hello, World!')
  end

  def test_it_iterates_counter_each_time_page_is_requested
    response = @conn.get('/')
    counter = response.body.scan(/\((.*)\)/).dig(0,0).to_i
    4.times { @conn.get('/') }
    new_response = @conn.get('/')
    counter_plus_5 = new_response.body.scan(/\((.*)\)/).dig(0,0).to_i
    difference = counter_plus_5 - counter
    assert_equal 5, difference
  end


end
