class FreshManController < ApplicationController
  include PriseHelper

  def give_prise
	user = current_user
	if not user.fresh_man_tour_finished
      user.fresh_man_tour_finished = true
	  prise_for(user).with(SuperMissionPrise.all.entries.first, 'super mission').give!
	  user.save
    end
  end
  
  def prise
	render json: format_prise(SuperMissionPrise.all.entries.first)
  end
  
end