require 'erb'
require 'active_support/inflector'
#require 'active_support/core_text'
require_relative 'params'
require_relative 'session'


class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(req, route_params)

  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    #response = HTTPResponse.new(content_type: type, body: content)
    self.res.body, self.res.content_type = content, type
    session.store_session(self.res)

    if already_rendered?
      raise "Can't render/redirect twice"
    end

    #following might be wrong b/c of no setter
    @already_built_response = true
    nil
    #response
  end

  # helper method to alias @already_rendered
  def already_rendered?
    @already_built_response
  end

  # set the response status code and header
  def redirect_to(url)
    self.res.status = 302
    #how would I know about location
    self.res.header["location"] = url
    session.store_session(self.res)

    #self.res.set_redirect(WEBrick::HTTPStatus::TemporaryRedirect, url)
    if already_rendered?
      raise "Can't render/redirect twice"
    end

    #following might be wrong b/c of no setter
    @already_built_response = true
    nil
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    #Open template, put content into string-content
    cntrl_name = self.class.to_s.underscore

    erb_temp = File.read("views/#{cntrl_name}/#{template_name}.html.erb")
    content = ERB.new(erb_temp).result(binding)

    render_content(content , 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    #Rails Magic: Default calls render on appropriate method even if the programmer doesn't :
    render(name) unless already_rendered?
  end
end
