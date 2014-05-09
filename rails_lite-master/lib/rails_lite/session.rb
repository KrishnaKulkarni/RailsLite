require 'json'
require 'webrick'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    cookie = req.cookies.detect{ |cookie| cookie.name == '_rails_lite_app'}
    sess_json = cookie ? cookie.value : nil
    
    if sess_json
      @sess_hash = JSON.parse(sess_json)
    else
      @sess_hash = {}
    end
  end

  def [](key)
    @sess_hash[key]
  end

  def []=(key, val)
    @sess_hash[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    cookie = WEBrick::Cookie.new('_rails_lite_app', @sess_hash.to_json)
    res.cookies << cookie
    
    cookie
  end
end
