class DevHookController < ApplicationController
  def index
    puts session.as_json
    id = ApplicationHelper.check_int_param params[:id]

    if true#id < 100 and id > 0
      sign_in User.find id

      render :json => 1
    else
      render :json => 0
    end
  end
end
