module IframeHelper
  def _sign_out
    if user_signed_in? 
      sign_out current_user
    end
  end

  def check_provider
    @current_provider = params[:provider]

    unless @current_provider and ! @current_provider.empty? and MEGABALL_IFRAME_CONFIG.has_key?(@current_provider)
      @current_provider = nil
    end

    if iframe?
      #_sign_out
      send(@current_provider)
    else
      unless cookies[:provider].nil?
        _sign_out
        cookies.delete :provider
      end
    end
  end

  def vk
    _sign_out

    return if params[:vktoken] != 'KDFigmsda2987fsdfihcaASDS'

    uid = params[:viewer_id]

    if !uid.nil?
      uid = uid.to_i
    end

    auth_key = params[:auth_key]

    if !auth_key.nil?
      auth_key = auth_key.to_s
    end

    authorized_in_vk = false

    if auth_key == Digest::MD5.hexdigest(MEGABALL_IFRAME_CONFIG[@current_provider]['id'].to_s + 
      '_' + uid.to_s + '_' + MEGABALL_IFRAME_CONFIG[@current_provider]['secret_key'])
      authorized_in_vk = true
    end

    if authorized_in_vk
      cookies[:provider] = "vk"

      vk_app = VK::Application.new app_id: MEGABALL_IFRAME_CONFIG[@current_provider]['id'], 
        app_secret: MEGABALL_IFRAME_CONFIG[@current_provider]['secret_key']
      vk_app.authorize(type: :secure)

      result = vk_app.vk_call('secure.checkToken', {
        client_secret: MEGABALL_IFRAME_CONFIG[@current_provider]['secret_key'],
        token: params[:access_token]
      })
      return _sign_out if result['success'].to_i != 1 || result['date'].to_i < 1401708730 # dirty fix

      info = {}

      api_result = nil
      api_result = JSON.parse(params[:api_result]) if !params[:api_result].nil?
      api_result = api_result["response"][0] if !api_result.nil? and !api_result["response"].nil? and api_result["response"].kind_of?(Array) and !api_result["response"].empty?

      if !api_result.nil?
        info[:nickname] = (api_result["first_name"] || "") + ' ' + (api_result["last_name"] || "")
        info[:sex] = if api_result["sex"] == 2 then 'male' \
                    elsif api_result["sex"] == 1 then 'female' \
                    else 'unknown' end
        info[:bdate] = api_result["bdate"]
      end

      locale = case params[:language]
               when '3' then 'en'
               else 'ru' 
               end
      ref = params[:referrer][0..20]

      user = User.find_for_provider_oauth('vkontakte', {
        uid: uid, 
        info: info,
        zone: 'russian',
        locale: locale,
        ref: ref
      }, nil)
      user.set(:locale, locale) if user.locale != locale

      puts "User to sign in: #{user.id}. Valid? #{user.valid?}. Persisted? #{user.persisted?}"
      if user.persisted?
        puts "Signing in"
        sign_in user, :event => :authentication #this will throw if @user is not activated 
      end
    end
  end

  def fb
    signed_request = params[:signed_request]

    if !signed_request.nil? and !signed_request.empty?
      _sign_out
      signature, fb_data_raw = signed_request.split(/\./)

      if signature.nil? or signature.empty? or fb_data_raw.nil? or fb_data_raw.empty?
        return
      end

      signature = signature.tr('-_', '+/')
      fb_data = fb_data_raw.tr('-_', '+/')
      signature = Base64.decode64(signature + '=')
      fb_data = Base64.decode64(fb_data + '=')

      unless signature == OpenSSL::HMAC.digest('sha256', 
        MEGABALL_IFRAME_CONFIG[@current_provider]['secret_key'], fb_data_raw)
        return
      end

      fb_data = JSON.parse(fb_data)

      locale = 'en'
      unless fb_data['user'].nil?
        fb_locale = fb_data['user']['locale']
        locale = if /(^ru_|^uk_)/ =~ fb_locale
                   'ru'
                 else
                   'en'
                 end
      end

      cookies[:provider] = "fb"

      user_id = fb_data['user_id']

      if not user_id.nil?
        user = User.find_for_provider_oauth('facebook', {
          uid: user_id, 
          info: {},
          zone: 'english',
          locale: locale,
        }, nil)
        user.set(:locale, locale) if user.locale != locale

        if user.persisted?
          sign_in user, :event => :authentication # this will throw if @user is not activated 
        end
      else
        redirect_to({
          controller: 'fb_auth',
          action: 'index',
          provider: @current_provider
        })
      end
    end
  end

  def ok
    _sign_out
    uid = params[:logged_user_id]

    if !uid.nil?
      uid = uid.to_i
    end

    auth_key = params[:auth_sig]

    if !auth_key.nil?
      auth_key = auth_key.to_s
    end

    session_key = params[:session_key]

    if !session_key.nil?
      session_key = session_key.to_s
    end

    session_secret_key = params[:session_secret_key]

    if !session_secret_key.nil?
      session_secret_key = session_secret_key.to_s
    end

    application_key = params[:application_key]

    if !application_key.nil?
      application_key = application_key.to_s
    end

    api_server = params[:api_server]

    if !api_server.nil?
      api_server = api_server.to_s
    end

    authorized_in = false

    if auth_key == Digest::MD5.hexdigest(uid.to_s + session_key + MEGABALL_IFRAME_CONFIG[@current_provider]['secret_key'])
      authorized_in = true
    end

    if authorized_in
      cookies[:provider] = "ok"

      info = {}

      user = User.find_for_provider_oauth('odnoklassniki', {
        uid: uid, 
        info: info,
        zone: 'russian',
        locale: 'ru'
      }, nil)

      if user.persisted?
        sign_in user, :event => :authentication #this will throw if @user is not activated 
      end
    end
  end

  def mailru
    _sign_out
    uid = params[:vid]

    if !uid.nil?
      uid = uid.to_i
    end

    auth_key = params[:sig]

    if !auth_key.nil?
      auth_key = auth_key.to_s
    end

    session_key = params[:session_key]

    if !session_key.nil?
      session_key = session_key.to_s
    end

    authorized_in = false

    exclude = ['sig', 'provider', 'unity_file']
    digest = Digest::MD5.hexdigest(
      request.query_parameters
             .sort
             .map{ |key, value| "#{key}=#{value}" unless exclude.include? key }
             .join +
       MEGABALL_IFRAME_CONFIG[@current_provider]['secret_key']
    )

    if auth_key == digest
      authorized_in = true
    end

    if authorized_in
      cookies[:provider] = "mailru"

      mailru_app = MailRU::API.new app_id: MEGABALL_IFRAME_CONFIG[@current_provider]['id'], 
        secret_key: MEGABALL_IFRAME_CONFIG[@current_provider]['secret_key'], 
        session_key: session_key

      begin
        users = mailru_app.users.get_info(:uids => [uid])
      rescue
        ;
      end

      info = {}

      if !users.empty?
        current_mailru_user = users[0]

        info[:nickname] = current_mailru_user["first_name"] + ' ' + current_mailru_user["last_name"]
      end

      mailru_app.users.get_info 

      user = User.find_for_provider_oauth('mailru', {
        uid: uid, 
        info: info,
        zone: 'russian',
        locale: 'ru'
      }, nil)

      if user.persisted?
        sign_in user, :event => :authentication #this will throw if @user is not activated 
      end
    end
  end

  def iframe?
    !@current_provider.nil?
  end
end
