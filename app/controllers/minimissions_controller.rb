class MinimissionsController < ApplicationController
  include DailyMissionHelper
  include PriseHelper
  include LocaleHelper

  before_filter :authenticate_user!
  before_filter :set_locale

  def index
    render json: (daily_missions.map do |mission|
      format_prise(mission.as_json.merge!({
        completed: mission.achieved?(current_user),
        progress: Hash[mission.params.map do |key, val|
          user_attr = current_user.attr_by_string(key) || 0
          miss_attr = current_user.daily_mission_backup[key] || 0
          [key, user_attr - miss_attr]
        end]
      }))
    end)
  end
end
