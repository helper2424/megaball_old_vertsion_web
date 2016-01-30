class UserLog
  include Mongoid::Document

  auto_increment :_id, :seed  => 0

  field :user_id, type: Integer
  field :log, type: String, default: ""
  field :date_created, type: DateTime, default: ->{ DateTime.now }

  validate :frequency

  def frequency
    last_log = UserLog.where(user_id: user_id).last
    return if last_log.nil?
    diff = (date_created - last_log.date_created).to_i
    errors.add :date_created, 'Too frequent' if diff <= 60
  end

end
