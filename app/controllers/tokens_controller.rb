class TokensController < ApplicationController
  # POST /tokens/create
  # POST /tokens/create.json
  # curl -X POST -d id=1 127.0.0.1:3000/tokens/create

  before_filter :authenticate_user!

  def create

    result = TokenValidator.create(current_user)

    event_server = EventServer.first

    #respond_to do |format|
      if event_server.nil?
        #format.json { 
        render :json => {:token => result[0], 
          :event_server_address => nil,
          :event_server_port => nil },
          :status => result[1] 
      else
        #format.json { 
        render :json => {:token => result[0],
          :event_server_address => event_server.address,
          :event_server_port => event_server.port },
          :status => result[1]
        #}
      end
    #end
  end

end