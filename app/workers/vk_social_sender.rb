class VkSocialSender
  include Sidekiq::Worker

  def perform vk_uis, message, config      
    vk_app = VK::Application.new app_id: config['id'], app_secret: config['secret_key']
    vk_app.authorize(type: :secure)

    res = vk_app.vk_call 'secure.sendNotification', { user_ids: vk_uis, message: message, client_secret: config['secret_key']}
    Rails.logger.debug(res)
  end
end