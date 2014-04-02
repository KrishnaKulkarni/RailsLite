require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  #attr_reader :params

  def initialize(req, route_params = {})
    @params = route_params.merge!(parse_www_encoded_form(req.query_string))
    .merge!(parse_www_encoded_form(req.body))

    #read req.body
    #@params.merge!(parse_www_encoded_form(read_body))

  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
    @permitted_keys = [] if @permitted_keys.nil?
    @permitted_keys +=  keys
  end

  def require(key)
    raise AttributeNotFoundError.new unless @params.has_key?(key)
    @params[key]
  end

  def permitted?(key)
    @permitted_keys.include? key
  end

  def to_s
    @params.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  #private

  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }

  #user[address][street]=main&user[address][zip]=89436&user[phone]=7132400060

  #Assign

  def parse_www_encoded_form(www_encoded_form)
    return {} if www_encoded_form.nil?

    raw_arrays = URI.decode_www_form(www_encoded_form).map { |pair| parse_key(pair.first) + [pair.last] }
    params = {}

    raw_arrays.each do |arr|
      curr_hash = params
      arr.each_with_index do |elem, idx|

        if(idx == arr.length - 2)
          curr_hash[elem] = arr.last
          break
        end

        if curr_hash.has_key?(elem)
          curr_hash = curr_hash[elem]
        else
          curr_hash.merge!(build_nest_hash(arr[idx...arr.length]))
          break
        end
      end
    end

    params
  end


#['user', 'address', 'street', 'main'] => {  }
  def build_nest_hash(arr)
    raise "A hash must have at least 2 inputs: key and value" unless arr.length >= 2
    return { arr.first => arr.last } if arr.length == 2

    build_nest_hash(arr[0...arr.length - 2] + [{ arr[-2] => arr[-1] }])
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.gsub("]", "").split("[")
  end
end
