class Ability
  include CanCan::Ability

  def initialize(user)

    can [:all,
         :show,
         :byids,
         :user], :clubs

    if user.club_user.nil?
      can [:new_club,
           :join], :clubs
    else

      can [:leave], :clubs

      can [:to_club], :transfers

      if user.club_user.administrator?
      end

      if user.club_user.moderator?
        can [:rename, 
             :role, 
             :show_requests, 
             :accept, 
             :reject,
             :reject_all,
             :kick,
             :update,
             :update_logo,
             :upgrade], :clubs
      end
    end
  end
end
