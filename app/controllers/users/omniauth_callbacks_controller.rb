class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook
    oauth_provider 'facebook'
  end

  def twitter
    oauth_provider 'twitter'
  end

  def vkontakte
    oauth_provider 'vkontakte'
  end

  def odnoklassniki
    oauth_provider 'odnoklassniki'
  end

  def google_oauth2
    oauth_provider 'google_oauth2' 
  end

  def mailru
    oauth_provider 'mailru'
  end
  
private
  def oauth_provider name
    if current_user
      redirect_to root_path
      return
    end

    if request.env["omniauth.auth"][:uid]
      @user = User.find_for_provider_oauth(name, request.env["omniauth.auth"], current_user)
    else
      @user = nil 
    end

    # FIX it (Если пользователь привязывает новую соц. сеть, хотя до этого уже 
    # привязал её к другому акку в нашей системе)
    unless @user
      render :text => 'Error'
      return
    end

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => name) if is_navigational_format?
    else
      redirect_to new_user_registration_url
    end
  end

end