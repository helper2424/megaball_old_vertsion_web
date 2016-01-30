class InvitesController < ApplicationController

  before_filter :authenticate_user!

  def index
  end

  def check

    if current_user.active?
      redirect_to root_path, params: request.GET
      return
    end

    invite = nil

    params[:invite] = params[:invite].to_s()[0..100]

    if params[:invite] =~ /^[0-9A-F]+$/i 
      invite = params[:invite]
    end

    invite = Invite.where(:text_hash => invite, :destination.exists => false).first

    if invite
      invite.update_attributes :destination => current_user._id, date: Time.new 
      current_user.update_attributes :active => true

      redirect_to controller: :main, action: :index, params: request.GET
      return
    end

    @error = t :incorrect_invite
    render template: 'invites/index'
  end

  def generate
    has_invite = Invite.where(:source => current_user._id, :destination.exists => false).first

    @hash = ''

    if has_invite
      @hash = has_invite.text_hash
    else
      invite = Invite.create :source => current_user._id, 
        :text_hash => SecureRandom.hex(20)

      @hash = invite.text_hash
    end

    render :json => {invite: @hash} 
  end
end
