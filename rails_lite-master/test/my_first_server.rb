require 'erb'
require 'active_support/inflector'
#require 'active_support/core_text'
require_relative '../lib/rails_lite/controller_base'

require 'webrick'

#root = File.expand_path '~/public_html'
server = WEBrick::HTTPServer.new(:Port => 8080) #, :DocumentRoot => root)


server.mount_proc('/') do |req, res|
  #ControllerBase.new(req, res).redirect_to('http://google.com')
  res.content_type = 'text/text'
  res.body = req.path
end


##
trap('INT') { server.shutdown }

server.start