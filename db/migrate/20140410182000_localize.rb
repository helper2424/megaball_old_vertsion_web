# encoding: utf-8

class Localize < ActiveRecord::Migration
  def up
    def localize model, field
      backup = Hash[model.all.map { |x| [x.id, x[field]] }]
      model.all.set(field, {})
      model.all.each { |x| x.send("#{field.to_s}=".to_sym, backup[x.id]); x.save }
    end

    puts "Localizing items"
    localize Item, :title
    localize Item, :description
    puts "Localizing achievements"
    localize Achievement, :title
    localize Achievement, :description
    puts "Localizing daily missions"
    localize DailyMission, :title
    localize DailyMission, :description
    puts "Localizing game plays"
    localize GamePlay, :name
  end

  def down
  end
end
