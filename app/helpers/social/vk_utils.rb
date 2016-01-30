class VkUtils < SocialUtils
  @@app = nil
  CurrentProvider = 'vk'

  def initialize(uid)
    if @@app.nil?
      @@app = VK::Application.new({
        app_id: MEGABALL_IFRAME_CONFIG[CurrentProvider]['id'], 
        app_secret: MEGABALL_IFRAME_CONFIG[CurrentProvider]['secret_key'], 
      })
      @@app.authorize type: :secure
    end
    @uid = uid
  end

  def notify(msg)
    puts "Notify friend with '#{msg}'"
    vk_call 'secure.sendNotification', user_ids: [@uid], message: msg
  end

  private 
  
  def vk_call(method, opts={})
    return nil if @@app.nil?
    opts['client_secret'] = MEGABALL_IFRAME_CONFIG[CurrentProvider]['secret_key']
    begin
      @@app.vk_call method, opts
    rescue
      nil
    end
  end
end
