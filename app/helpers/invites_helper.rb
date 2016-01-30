module InvitesHelper
  def check_invite

    unless MEGABALL_CONFIG['invites']
      return
    end

    unless current_user 
      return
    end

    unless current_user.active?
      redirect_to controller: :invites, action: :check, params: request.GET
    end
  end
end
