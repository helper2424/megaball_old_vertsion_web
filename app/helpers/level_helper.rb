module LevelHelper
  include PriseHelper

  def check_level!
    user = current_user
    prev_level = level_from_exp user.last_experience
    curr_level = level_from_exp user.experience

    if curr_level > prev_level
      user.last_experience = user.experience
      user.points += (curr_level - prev_level) * MEGABALL_CONFIG['points_per_level']
      user.save

      reaches = LevelReachPrise.in_range(prev_level, curr_level)
      reaches.inject(prise_for(user)) { |prise, reach| prise.with reach, :level_reach }
             .give!

      Message.create message: curr_level.to_s, type: 'levelup', user_id: user.id
      StatsWorker.perform_for_user(user, 'levelup', {
        quantity: curr_level,
        custom: {
          prev_level: prev_level,
          curr_level: curr_level,
          points: user.points,
          experience: user.experience
        }
      })

      true
    else
      false
    end
  end

  def level_from_exp exp
    @user_default ||= UserDefault.first
    @user_default.levels.select { |x| x <= (exp || 0) }.length
  end
end
