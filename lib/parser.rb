class Parser
  attr_reader :request,
              :parsed_request

  def initialize(request)
    @request = request
    @parsed_request = get_request_hash
  end

  def parse
    diagnostic = { verb: find_verb,
                   path: find_path,
                   param: get_param,
                   protocol: get_protocol,
                   host: get_host,
                   port: get_port,
                   origin: get_origin,
                   accept: get_accept,
                   content_length: get_content_length
    }
  end

  def get_request_hash
    partial_request = request[1..-1]
    partial_request.map { |e| e.split(': ') }.to_h
  end

  def find_verb
    request.first.split[0]
  end

  def get_protocol
    request.first.split[2]
  end

  def get_host
    parsed_request["Host"].split(':').first
  end

  def get_port
    parsed_request["Host"].split(':').last
  end

  def get_origin
    return parsed_request["Origin"] if origin?
    "Are you too good for your home?"
  end

  def origin?
    parsed_request.has_key?("Origin")
  end

  def get_accept
    parsed_request["Accept"]
  end

  def get_content_length
    parsed_request["Content-Length"].to_i
  end

  def find_path
    path = request.first.split[1].scan(/\/(\w*)/).dig(0,0)
    return path unless path.empty?
    "root"
  end

  def get_param
    return request.first.split[1].scan(/\?\w*=(\w*)/).dig(0,0).downcase if params?
    "Nary a pair of rams to be found."
  end

  def params?
    request.first.split[1].include?('?')
  end
end
