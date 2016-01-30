module LocaleHelper
  def set_locale
    if params.include? :locale
      I18n.locale = params[:locale].to_sym
    elsif not current_user.nil? and not current_user.locale.nil?
      I18n.locale = current_user.locale.to_sym
    end
  end
end
