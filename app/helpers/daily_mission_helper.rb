module DailyMissionHelper
  include PriseHelper

  DAILY_MISSION_TYPES = [0, 1, 2]

  def daily_missions
    @daily_missions_memo ||= DailyMission.with_ids((
      DailyMissionRecord.today.first ||
      DailyMissionRecord.create(entries: rand_daily_missions(DAILY_MISSION_TYPES).map(&:_id))
    ).entries).entries
  end

  def achieved_missions
    daily_missions.reject { |m| not m.achieved?(current_user) }
  end

  def check_daily_mission!
    prises = PriseTransaction.today
                             .with_user(current_user)
                             .with_reason(:daily_mission)
                             .with_contents(achieved_missions.map(&:_id))
                             .entries
                             .map(&:content)
    new_missions = achieved_missions.reject { |m| prises.include? m.id }
    new_missions
      .inject(prise_for(current_user)) { |p, m| p.with m, :daily_mission }
      .give!
    new_missions
  end 

  def daily_mission_backup!
    last_backup = current_user.daily_mission_backup['last_backup']
    if last_backup.nil? or last_backup.to_i < Time.now.beginning_of_day.to_i
      hash = daily_missions.map(&:params)
                           .map(&:keys)
                           .flatten(1)
                           .map { |x| [x, current_user.attr_by_string(x)] }
                           .inject({}) { |r, x| r.merge!({ x[0] => x[1] }) }
                           .merge!({ 'last_backup' => Time.now.to_i })
                           .as_json
      current_user.set(:daily_mission_backup, hash)
      puts hash
    end
  end

  def rand_daily_missions types = [0, 1, 2]
    samples = []
    types.each do |i| 
      samples << random_mission(type: i, except: samples)
    end
    samples.reject(&:nil?)
  end

  def random_mission opts = {} 
    type = opts[:type] || 0
    except = opts[:except] || []

    sample = DailyMission.where(:type => type) 
    sample = sample.where(:_id.nin => except.map(&:_id))

    random = sample.where(:random.gte => rand)
    (random.count > 0) ? random.first : sample.last
  end
end
