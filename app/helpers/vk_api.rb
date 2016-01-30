module VkApi
  def self.setup 
    @@config = { }

    yield(@@config)
  end

  def call 
    url = URI.parse(@@config[:base_url])
    res = Net::HTTP.get(url.host, url.port) 
    puts res.body
  end

  def set_access_token token 
    @access_token = token 
  end

  # crontab -e 0 17 * * * cd /home/r3studio/megaball_web && echo "VkApi.daily_notification" | sudo -u r3studio rails c release
  def self.daily_notification
    phrases = MEGABALL_CONFIG['notification_phrases']
    message = phrases.sample

    vk_app = VK::Application.new app_id: MEGABALL_IFRAME_CONFIG['vk']['id'], app_secret: MEGABALL_IFRAME_CONFIG['vk']['secret_key']
    vk_app.authorize(type: :secure)

    note_ids = []
    called = false
    User.gt(_id: MEGABALL_CONFIG['bots_border']).where("oauth_providers.provider" => "vkontakte").each do |user|
      unless user.oauth_providers.nil?
        user.oauth_providers.each do |op|
          if op.provider == 'vkontakte'
            note_ids << op.uid
          end
        end

        if note_ids.count >= 100
          puts note_ids
          message = phrases.sample
          puts message
          vk_app.vk_call 'secure.sendNotification', {user_ids:note_ids, message: message, client_secret: MEGABALL_IFRAME_CONFIG['vk']['secret_key']}
          note_ids = []
          sleep 3
          called = true
        end
      end
    end

    if !called
      vk_app.vk_call 'secure.sendNotification', {user_ids:note_ids, message: message, client_secret: MEGABALL_IFRAME_CONFIG['vk']['secret_key']}
      puts note_ids
    end

    phrases.sample
  end

  def self.send_notification message
    vk_app = VK::Application.new app_id: MEGABALL_IFRAME_CONFIG['vk']['id'], app_secret: MEGABALL_IFRAME_CONFIG['vk']['secret_key']
    vk_app.authorize(type: :secure)

    note_ids = []
    called = false
    User.each do |user|
      unless user.oauth_providers.nil?
        user.oauth_providers.each do |op|
          if op.provider == 'vkontakte'
            note_ids << op.uid
          end
        end

        if note_ids.count >= 100
          puts note_ids
          vk_app.vk_call 'secure.sendNotification', {user_ids:note_ids, message: message, client_secret: MEGABALL_IFRAME_CONFIG['vk']['secret_key']}
          note_ids = []
          sleep 3
          called = true
        end
      end
    end

    if !called
      vk_app.vk_call 'secure.sendNotification', {user_ids:note_ids, message: message, client_secret: MEGABALL_IFRAME_CONFIG['vk']['secret_key']}
      put note_ids
    end
  end

  def self.return_yestarday_users
  end
  def self.return_users
  end
end

