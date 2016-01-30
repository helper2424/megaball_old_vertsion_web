require 'spec_helper'

describe ManaHelper do
  after :each do
    teardown!
    Timecop.return
  end

  def create_vip user, charges = 5
    w = UserWeapon.new(light_vip: true)
    w.charge = charges
    w.user_id = user.id
    w.save
  end
  
  it "should return factor according to user_defaults" do
    new_user

    expect(mana_restore_factor_for current_user).to eq(0)

    create_vip current_user, 0
    expect(mana_restore_factor_for current_user).to eq(0)
    UserWeapon.delete_all

    create_vip current_user, 1
    expect(mana_restore_factor_for current_user).to eq(0.3)
    UserWeapon.delete_all

    create_vip current_user, 3
    expect(mana_restore_factor_for current_user).to eq(0.3)
    UserWeapon.delete_all

    create_vip current_user, 7
    expect(mana_restore_factor_for current_user).to eq(0.4)
    UserWeapon.delete_all

    create_vip current_user, 8
    expect(mana_restore_factor_for current_user).to eq(0.4)
    UserWeapon.delete_all

    create_vip current_user, 30
    expect(mana_restore_factor_for current_user).to eq(0.5)
    UserWeapon.delete_all

    create_vip current_user, 35
    expect(mana_restore_factor_for current_user).to eq(0.5)
    UserWeapon.delete_all
  end

  it "should restore mana for vips" do
    new_user
    create_vip current_user

    check_vip_mana!
    refresh_user
    current_user.set(:mana, 0)

    Timecop.travel(Time.now + 4.minutes)
    check_vip_mana!
    refresh_user

    expect(current_user.mana).to eq((mana_restore_factor_for(current_user) * 4).round)
  end

  it "should not restore mana for vips when it's full" do
    new_user
    create_vip current_user

    check_vip_mana!
    refresh_user
    current_user.set(:mana, current_user.mana_max)

    Timecop.travel(Time.now + 4.minutes)
    check_vip_mana!
    refresh_user

    expect(current_user.mana).to eq(current_user.mana_max)
  end

  it "should not restore mana without vip" do
    new_user

    check_vip_mana!
    refresh_user
    current_user.set(:mana, 0)

    Timecop.travel(Time.now + 4.minutes)
    check_vip_mana!
    refresh_user

    expect(current_user.mana).to eq(0)
  end

  it "should increase mana every day" do
    new_user

    check_mana!
    refresh_user
    current_user.set(:mana, 0)

    Timecop.travel(Time.now + 1.day)

    check_mana!
    refresh_user
    expect(current_user.mana).to eq(UserDefault.first.mana_daily)

    Timecop.travel(Time.now + 1.day)

    check_mana!
    refresh_user
    expect(current_user.mana).to eq(UserDefault.first.mana_daily * 2)
  end

  it "shouldn't increase mana twice a day" do
    new_user

    check_mana!
    refresh_user
    current_user.set(:mana, 0)

    Timecop.travel(Time.now + 1.day)

    check_mana!
    refresh_user
    expect(current_user.mana).to eq(UserDefault.first.mana_daily)

    check_mana!
    refresh_user
    expect(current_user.mana).to eq(UserDefault.first.mana_daily)
  end
end

