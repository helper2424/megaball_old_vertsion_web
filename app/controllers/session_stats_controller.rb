class SessionStatsController < ApplicationController
  include ErrorsHelper

  before_filter :authenticate_user!

  SAVE_INTERVAL = 20

  def create

    user = current_user
    if !user.last_session_save.nil? && \
        (Time.now.to_i - user.last_session_save) < SAVE_INTERVAL
      return render_error :too_frequent
    end
    
    fast_matches = (params[:fast_matches] || 0).to_i
    trainings    = (params[:trainings] || 0).to_i
    matches_diff = (trainings == 0) ? 0 : (fast_matches / trainings)

    played_games = params[:wins].to_f + params[:draws].to_f + params[:defeats].to_f

    StatsWorker.perform_for_user(current_user, :session, {
      custom: {
        level: current_user.level,
        days_in_game: current_user.days_in_game,
        session_end:  (params[:session_end] || 0).to_i,
        duration:     (params[:duration] || 0).to_f,
        energy:       (params[:energy] || 0).to_i,
        mana:         (params[:mana] || 0).to_i,
        coins:        (params[:coins] || 0).to_i,
        stars:        (params[:stars] || 0).to_i,
        wins:         (params[:wins] || 0).to_i,
        draws:        (params[:draws] || 0).to_i,
        defeats:      (params[:defeats] || 0).to_i,
        wins_perc:    (params[:wins].to_f / played_games),
        defeats_perc: (params[:defeats].to_f / played_games),
        fast_matches: fast_matches,
        trainings:    trainings,
        matches_diff: matches_diff
      }
    })

    user.last_session_save = Time.now
    user.save!
    render json: {}
  end
end
