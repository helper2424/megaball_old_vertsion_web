class ServersController < ApplicationController

  before_filter :authenticate_user!

  def game_server_list
    @servers = GameServer.all

    render json: @servers
  end
  
  def club_chat_server
    @user = current_user
    @club = @user.club
    unless @club.nil?
      @server = ChatServer.order_by([:_id, :asc])
      if @server.count > 0
        @server = @server[@club._id % @server.count]
        @user.room_id = "club_#{@club._id}"
        @user.save
        return render json: { 
          server: "#{@server.address}:#{@server.port}"
        }
      end
    end
    render json: { server: nil }
  end
end
