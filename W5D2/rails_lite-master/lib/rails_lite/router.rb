class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern, @http_method, @controller_class, @action_name = pattern, http_method, controller_class, action_name
  end

  # checks if pattern matches path and method matches request method
  def matches?(req)
    return false unless self.http_method == req.request_method.downcase.to_sym
    !!self.pattern.match(req.path)
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(req, res)
   ### raise "cannot run non_matching request" unless matches?(req) ##
    @route_params = {}
    match_data = self.pattern.match(req.path)
    match_data.names.each do |name|
      @route_params[name] = match_data[name]
    end

    self.controller_class.new(req, res, @route_params)
    .invoke_action(self.action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  # simply adds a new route to the list of routes
  def add_route(pattern, method, controller_class, action_name)
    self.routes << Route.new(pattern, method, controller_class, action_name)
  end

  # evaluate the proc in the context of the instance
  # for syntactic sugar :)
  def draw(&proc)
    self.instance_eval(&proc)
  end

  # make each of these methods that
  # when called add route
  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |path, controller, action|
      add_route(path, http_method, controller, action)
    end
  end

  # should return the route that matches this request
  def match(req)
    self.routes.detect { |route| route.matches?(req) }
  end

  # either throw 404 or call run on a matched route
  def run(req, res)
    matched_route = match(req)
    if matched_route.nil?
      res.status = 404
    else
      matched_route.run(req, res)
    end
  end
end
