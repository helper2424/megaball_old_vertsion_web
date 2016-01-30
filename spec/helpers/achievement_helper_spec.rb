require 'spec_helper'

describe AchievementHelper do
  def create title, uid, entries
    ach = Achievement.create title: title, unique_id: uid
    ach.achievement_entry += entries
    ach.save
    ach
  end

  before :each do
    @wins  = create 'wins', 1, [AchievementEntry.new(coins: 10, params: { wins:  10 }),
                                AchievementEntry.new(coins: 20, params: { wins:  100 }),
                                AchievementEntry.new(coins: 30, params: { wins:  1000 })]
    @goals = create 'goals', 2, [AchievementEntry.new(coins: 15, params: { goals: 10 }),
                                 AchievementEntry.new(coins: 25, params: { goals: 100 }),
                                 AchievementEntry.new(coins: 35, params: { goals: 1000 })]
  end

  after :each do
    teardown!
  end

  it "should create user_achievements" do
    new_user
    current_user.set(:user_achievement, [])
    check_achievements!
    refresh_user
    expect(current_user.user_achievement.map(&:achievement)).to eq([@wins.id, @goals.id])
    expect(current_user.user_achievement.map(&:stage).sum).to eq(0)
  end

  it "should achieve first stage" do
    new_user
    current_user.set(:goals, 50)
    check_achievements!
    refresh_user
    expect(current_user.user_achievement_by_id(@goals.id).stage).to eq(1)
    expect(PriseTransaction.with_reason(:achievement).count).to eq(1)
  end

  it "should return achieved entries" do
    new_user
    current_user.set(:goals, 50)
    current_user.set(:wins, 0)
    result = check_achievements!.as_json

    expect(result.count).to eq(1)
    expect(result[0]['_id']).to eq(@goals.id)
    expect(result[0]['title']).to eq(@goals.title)
    expect(result[0]['picture']).to eq(@goals.picture)
    expect(result[0]['description']).to eq(@goals.description)
    expect(result[0]['stage']).to eq(1)
    expect(result[0]['achievement_entry'].count).to eq(1)
    expect(result[0]['achievement_entry'][0]['coins']).to eq(15)
    expect(result[0]['achievement_entry'][0]['stars']).to eq(0)
    expect(result[0]['achievement_entry'][0]['items'].count).to eq(0)
  end

  it "should return multiple achieved entries" do
    new_user
    current_user.set(:goals, 50)
    current_user.set(:wins, 50)
    result = check_achievements!

    expect(result.count).to eq(2)
  end

  it "should achieve when all stages are done" do
    new_user
    current_user.set(:goals, 1000)
    current_user.set(:wins, 0)
    check_achievements!
    refresh_user
    expect(current_user.user_achievement_by_id(@goals.id).stage).to eq(3)
    expect(current_user.user_achievement_by_id(@goals.id).achieved).to be_true
    expect(current_user.user_achievement_by_id(@wins.id).stage).to eq(0)
    expect(current_user.user_achievement_by_id(@wins.id).achieved).to be_false

    current_user.set(:wins, 1000)
    check_achievements!
    refresh_user
    expect(current_user.user_achievement_by_id(@wins.id).stage).to eq(3)
    expect(current_user.user_achievement_by_id(@wins.id).achieved).to be_true
  end
  
end
