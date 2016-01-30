require 'spec_helper'

describe LevelHelper do
  def levelup
    current_user.set(:last_experience, 0)
    current_user.set(:experience, 100)
    check_level!
  end

  before :each do
    LevelReachPrise.create level: 1, coins: 10
    LevelReachPrise.create level: 2, coins: 10
    LevelReachPrise.create level: 3, coins: 10
  end

  after :each do
    teardown!
  end

  it "should give points when level is up" do
    new_user
    current_user.set(:points, 0)
    levelup
    refresh_user
    expect(current_user.points).to eq((current_user.level - 1) * # first level doesnt count
                                      MEGABALL_CONFIG['points_per_level'])
  end

  it "should return true when level is up" do
    new_user
    current_user.set(:last_experience, 0)
    current_user.set(:experience, 100)
    expect(check_level!).to be_true
    refresh_user
    expect(current_user.last_experience).to eq(100)
    expect(current_user.experience).to eq(100)
  end

  it "should return false when level is not up" do
    new_user
    current_user.set(:last_experience, 100)
    current_user.set(:experience, 100)
    expect(check_level!).to be_false
    refresh_user
    expect(current_user.last_experience).to eq(100)
    expect(current_user.experience).to eq(100)
  end
  
  it "should send message when level is up" do
    new_user
    Message.delete_all
    levelup
    expect(Message.where(type: 'levelup').count).to eq(1)
  end

  it "should restore energy when level is up" do
    new_user
    current_user.set(:energy, 0)
    levelup
    expect(current_user.energy).to eq(current_user.energy_max)
  end

  it "should give items for that level" do
    new_user
    levelup
    expect(PriseTransaction.with_reason(:level_reach).count).to eq(2)
  end

  after :all do
    Message.delete_all
  end
end
