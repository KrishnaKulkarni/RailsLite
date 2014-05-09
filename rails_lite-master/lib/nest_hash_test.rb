  def parse_www_encoded_form(www_encoded_form)
    return {} if www_encoded_form.nil?

    raw_arrays = URI.decode_www_form(www_encoded_form).map { |pair| parse_key(pair.first) + [pair.last] }
    params = {}
    puts "raw arrays:"
    p raw_arrays
    raw_arrays.each do |arr|
      curr_hash = params
      arr.each_with_index do |elem, idx|

        if idx == arr.length - 2
          curr_hash[elem] = arr.last
          break
        end

        if curr_hash.has_key?(elem)
          curr_hash = curr_hash[elem]
        else
          curr_hash[elem] = {}
          curr_hash = curr_hash[elem]
        end
      end
    end

    params
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.gsub("]", "").split("[")
  end
