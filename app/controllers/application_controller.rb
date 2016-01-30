class ApplicationController < ActionController::Base
  before_filter :set_cache_buster
  before_filter :try_clubs
  before_filter :reload_rails_admin, :if => :rails_admin_path?

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
  end

  def current_club
  end

  def current_club_user
  end

  private

  def try_clubs
  end

  def reload_rails_admin
    models = %W(Ball Weapon Item Collection)
    models.each do |m|
      RailsAdmin::Config.reset_model(m)
    end
    RailsAdmin::Config::Actions.reset

    load("#{Rails.root}/config/initializers/rails_admin.rb")
  end

  def rails_admin_path?
    controller_path =~ /rails_admin/ && Rails.env == "development"
  end
end
