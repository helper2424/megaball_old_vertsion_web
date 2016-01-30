class EnergyRequestsController < ApplicationController
  before_filter :authenticate_user!

  def create
    friend = User.find params[:friend_id].to_i
    if friend.been_today
      render json: { error: :been_today }
    else
      req = friend.energy_request_friend.create({
        receiver: current_user
      })
      render json: if req.valid?
        friend.social.notify t :help_friend
        req
      else
        { error: :cant_create_request }
      end
    end
  end
end
