class RoomController < ApplicationController

  before_filter :authenticate_user!
 
  # GET /rooms/check_password
  def check_password
    respond = { correct: false }
    if params.include? :id and params.include? :password
      room = Room.find params[:id]
      respond[:correct] = room.password == params[:password] if not room.nil?
    end
    render json: respond
  end

  # GET /rooms/train
  def train
    @rooms = Room.where type: 2, ready: true
    render json: @rooms
  end
  
  # GET /rooms/arena
  def arena
    @rooms = Room.where type: 3, ready: true
    render json: @rooms
  end

  # GET /rooms/fast
  def fast
    @rooms = Room.where type: 1, ready: true
    render json: @rooms
  end

end
