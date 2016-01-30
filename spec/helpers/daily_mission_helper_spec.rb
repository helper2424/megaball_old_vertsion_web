require 'spec_helper'

describe DailyMissionHelper do
  before :each do
    @w1 = DailyMission.create params: { wins: 100 }, coins: 10, type: 0
    @g1 = DailyMission.create params: { goals: 100 }, stars: 1, type: 1
    @w2 = DailyMission.create params: { wins: 200 }, coins: 20, type: 0
    @g2 = DailyMission.create params: { goals: 200 }, stars: 2, type: 1
    @w3 = DailyMission.create params: { wins: 300 }, coins: 30, type: 0
    @g3 = DailyMission.create params: { goals: 300 }, stars: 3, type: 1
  end

  after :each do
    teardown!
  end

  it "should take random mission with type" do
    expect(random_mission).not_to be_nil 
    expect(random_mission(type: 0).type).to eq(0)
    expect(random_mission(type: 1).type).to eq(1)
  end

  it "should generate ONE mission record on query" do
    2.times do
      expect(daily_missions.count).to be > 0
      expect(DailyMissionRecord.count).to eq(1)
    end
  end

  it "should backup current user's values" do
    new_user
    current_user.set(:goals, 10)
    current_user.set(:wins, 11)
    daily_mission_backup!
    refresh_user
    expect(current_user.daily_mission_backup['goals']).to eq(10)
    expect(current_user.daily_mission_backup['wins']).to eq(11)

    current_user.set(:goals, 20)
    current_user.set(:wins, 21)
    daily_mission_backup!
    refresh_user
    expect(current_user.daily_mission_backup['goals']).to eq(10)
    expect(current_user.daily_mission_backup['wins']).to eq(11)
  end

  it "should show return achieved missions" do
    new_user
    current_user.set(:wins, 0)
    current_user.set(:goals, 0)
    daily_mission_backup!
    expect(achieved_missions.count).to eq(0)

    current_user.set(:wins, 400)
    expect(achieved_missions.count).to eq(1)

    current_user.set(:goals, 400)
    expect(achieved_missions.count).to eq(2)
  end

  it "should give prise for achieved missions" do
    new_user
    current_user.set(:wins, 0)
    current_user.set(:goals, 0)
    daily_mission_backup!
    current_user.set(:wins, 400)
    current_user.set(:goals, 400)

    4.times { check_daily_mission! }

    expect(PriseTransaction.with_user(current_user)
                           .with_reason(:daily_mission)
                           .count).to eq(2)
  end

  it "should return newly achieved daily missions" do
    new_user
    current_user.set(:wins, 0)
    daily_mission_backup!
    current_user.set(:wins, 400)

    res = check_daily_mission!

    expect(res.count).to eq(1)
    expect([@w1.id, @w2.id, @w3.id]).to be_include(res[0].id)
  end
end
