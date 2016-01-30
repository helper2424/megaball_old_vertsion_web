module AchievementHelper
  include PriseHelper

  def check_achievements!
    user = current_user
    achievements = Achievement.all.to_a

    achieved = achievements
      .zip(achievements.map { |a| user.user_achievement_by_id a.id })
      .reject { |_, u| u.achieved }
      .map do |ach, user_ach|

        # give prise
        new_stage = ach_stage ach
        new_achievement = []
        ach.achievement_entry[user_ach.stage...new_stage].each do |entry|
          prise_for(user).with(entry, :achievement).give!
          new_achievement << entry
        end

        # store current achievement state
        user_ach.stage    = new_stage
        user_ach.achieved = user_ach.stage == ach.achievement_entry.count
        user_ach.status   = user_ach.achieved \
                            ? 100
                            : ach.achievement_entry[user_ach.stage]
                                 .status_for(user)

        if new_achievement.count <= 0
          nil
        else
          user_ach.as_json
                  .merge!({ achievement_entry: new_achievement.as_json })
                  .merge!(ach.as_json except: [:achievement_entry])
        end
      end
      .reject { |x| x.nil? }

    user.save

    achieved.map do |ach|
      ach[:achievement_entry] = ach[:achievement_entry].map do |entry|
        format_prise entry
      end
      ach
    end
  end

  def ach_stage ach
    user = current_user
    user_ach = user.user_achievement_by_id ach.id

    user_ach.stage + ach.achievement_entry
                        .each_with_index
                        .reject { |_, x| x < user_ach.stage }
                        .map { |x, _| x.achieved? user }
                        .map { |x| x ? 1 : 0 }
                        .sum
  end
end
