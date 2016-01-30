module ErrorsHelper
  def render_error msg=:unspecified, data={}
    render json: error(msg, data)
  end
  
  def error msg=:unspecified, data={}
    { error: msg }.merge(data)
  end
end
