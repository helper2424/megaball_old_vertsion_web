class GameController < ApplicationController
  include IframeHelper
  include InvitesHelper
  include DailyMissionHelper
  include RouletteHelper
  include LocaleHelper
  include ManaHelper
  include EnergyHelper
  include ExperienceHelper
  
  protect_from_forgery

  before_filter :check_provider
  before_filter :authenticate_user!
  before_filter :set_locale
  before_filter :check_invite
  before_filter :check_roulette_tickets!
  before_filter :check_mana!
  before_filter :check_energy_requests!
  before_filter :refresh_loss_vip_experience

  layout "game"

  def index
    @user = current_user
    oauth = @user.oauth_providers[0]
    @social_network = oauth.nil? ? "unspecified" : oauth.provider
    @social_uid = oauth.nil? ? "unspecified" : oauth.uid

    @locale = current_user.locale
    @plugin_status = current_user.plugin_status
    @iframe = iframe?
    @unity_file = (params.include? :unity_file) ?
                  params[:unity_file] : 
                  ActionController::Base.helpers.asset_path(
                    MEGABALL_CONFIG['unity_bin_name']
                  )

    ref = ""
    ref = params[:referrer][0..20] if params.include? :referrer

    @vk = (@current_provider == "vk")
    unless MEGABALL_IFRAME_CONFIG[@current_provider].nil?
      @app_id = MEGABALL_IFRAME_CONFIG[@current_provider]['id']
    end

    @visit_params = {
      ref: ref,
      days_in_game: current_user.days_in_game,
      level: current_user.level
    }

    StatsWorker.perform_for_user(current_user, :visit, { 
      ref: ref,
      custom: @visit_params
    })
  end
end
