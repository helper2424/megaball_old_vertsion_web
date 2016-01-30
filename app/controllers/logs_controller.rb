class LogsController < ApplicationController
  include LogsHelper
  layout 'logs'

  before_filter :authenticate_admin!

  def read_log(log, from = -1, lines = 20)
    data = IO.readlines(log)
    lower_bound = (from == -1) ? -1 * lines : from-data.length
    text = (lower_bound < -1 * data.length) ? data : data[lower_bound..-1]
    { count: data.length, lines: text }
  end

  def user_log(from = -1, lines = 20)
    log = UserLog.order_by([:date_created, :asc])
    count = log.count
    from = (from < 0) ? count - lines : from
    from = 0 if from < 0

    log =
      log.offset(from)
      .limit(lines) 
      .map { |s| "[#{s.date_created}] #{s.user_id}: #{s.log.gsub(/\n/, '<br/>')}" }
    { count: UserLog.count, lines: log }
  end

  def respond_log(log)
    respond_to do |format|
      format.html { render text: url_for(format: 'json'), :layout => true }
      format.json { render json: read_log(log, get_positive_int_param('from', -1), get_positive_int_param('lines', 20)) }
    end
  end

  def respond_custom_log(&block)
    respond_to do |format|
      format.html { render text: url_for(format: 'json'), :layout => true }
      format.json { render json: block.call(get_positive_int_param('from', -1), get_positive_int_param('lines', 20)) }
    end
  end

  def game_server
    respond_log MEGABALL_CONFIG['logs']['game_server']
  end

  def policy
    respond_log MEGABALL_CONFIG['logs']['policy']
  end

  def event
    respond_log MEGABALL_CONFIG['logs']['event']
  end

  def web_server
    respond_log MEGABALL_CONFIG['logs']['web_server']
  end

  def chat_server
    respond_log MEGABALL_CONFIG['logs']['chat_server']
  end

  def users
    respond_custom_log { |from, lines| user_log from, lines }
  end

  private 

  def authenticate_admin!
    authenticate_user!
    if Rails.env.release? and not current_user.admin?
      raise ActionController::RoutingError.new "Admins only"
    end
  end

end
