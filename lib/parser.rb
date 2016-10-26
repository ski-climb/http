class Parser
  attr_reader :request,
              :from_request

  def initialize(request)
    @request = request
    @from_request = get_request_hash
  end

  def parse
    diagnostic = { verb: get_verb,
                   path: find_path,
                   param: get_param,
                   protocol: get_protocol,
                   host: get_host,
                   port: get_port,
                   origin: get_origin,
                   accept: get_accept,
    }
  end

  def get_request_hash
    partial_request = request[1..-1]
    partial_request.map { |e| e.split(': ') }.to_h
  end

  def get_verb
    request.first.split[0]
  end

  def get_protocol
    request.first.split[2]
  end

  def get_host
    from_request["Host"].split(':').first
  end

  def get_port
    from_request["Host"].split(':').last
  end

  def get_origin
    return from_request["Origin"] if origin?
    "Are you too good for your home?"
  end

  def origin?
    from_request.has_key?("Origin")
  end

  def get_accept
    from_request["Accept"]
  end

  def find_path
    request.first.split[1].scan(/\/(\w*)/).dig(0,0)
  end

  def get_param
    return request.first.split[1].scan(/\?\w*=(\w*)/).dig(0,0).downcase if params?
    "Nary a pair of rams to be found."
  end

  def params?
    request.first.split[1].include?('?')
  end
end
