module ExperienceHelper
  def refresh_loss_vip_experience
    current_user.loss_of_experience_without_vip = 0
    current_user.save
  end
end
