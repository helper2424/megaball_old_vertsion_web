class HeaderDelete
  def initialize(app)
    @app = app
    @redundant_headers = [
      "X-Request-Id",
      "X-Runtime",
      "X-Rack-Cache"
    ]
  end

  def call(env)
    @res = @app.call env
    @status   = @res[0]
    @headers  = @res[1]
    @response = @res[2]

    @headers.delete_if { |key, value| @redundant_headers.include? key }
    [@status, @headers, @response]
  end
end
