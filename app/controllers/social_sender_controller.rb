#econding: utf-8

class SocialSenderController < ApplicationController
  def vkVolcanoNotification
    phrases = MEGABALL_CONFIG['energy_notification_phrases']    
    config  = MEGABALL_CONFIG['vk']

    max_energy = UserDefault.first.energy_max_restore
    restore_factor = UserDefault.first.average_energy_restore_factor
    time_for_total_restore = Time.now - (max_energy / restore_factor).minute
    users = User.lt(:last_energy_notification => Time.now - 1.day, :last_volcano_update => time_for_total_restore)
    uids = users.pluck(:oauth_providers)
                .map { |x| x[0]["uid"] }
    users.set(:last_energy_notification, Time.now)    
          
    uids.each_slice(100) do |ids|            
      VkSocialSender.perform_async ids, phrases.sample, config 
    end        
  end	
end