require 'spec_helper'

describe PriseHelper do
  after :each do
    teardown!
  end

  it "should give coins for prise" do
    new_user
    acid = current_user.acid
    acid.imagine_balance = 0
    acid.save!
    
    prise_for(current_user).with(PriseItem.new({
      coins: 10
    }), :test).give!

    @user = User.find(current_user.id)
    expect(@user.acid.imagine_balance).to eq(10)
    expect(@user.coins).to eq(10)
  end

  it "should give stars for prise" do
    new_user
    acid = current_user.acid
    acid.real_balance = 0
    acid.save!
    
    prise_for(current_user).with(PriseItem.new({
      stars: 10
    }), :test).give!

    @user = User.find(current_user.id)
    expect(@user.acid.real_balance).to eq(10)
    expect(@user.stars).to eq(10)
  end

  it "should give items for prise" do
    new_user
    current_user.hair = 0
    current_user.avail_hair = [0]
    current_user.save

    item = Item.create(title: 'test item')
    item.item_contents << ItemContent.new(content: 1488, count: 1, type: 'hair')
    item.save

    prise_for(current_user).with(PriseItem.new({
      items: [item.id]
    }), :test).give!

    @user = User.find(current_user.id)
    expect(@user.avail_hair).to be_include(1488)
  end

  it "should create prise transactions" do
    new_user
    
    prise_for(current_user).with(PriseItem.new({
      coins: 10
    }), :test).give!
    
    prise_for(current_user).with(PriseItem.new({
      stars: 10
    }), :test).give!

    expect(PriseTransaction.count).to eq(2)
  end

  it "should give multiple prises" do
    new_user
    acid = current_user.acid
    acid.imagine_balance = 0
    acid.real_balance = 0
    acid.save!
    
    prise_for(current_user)
    .with(PriseItem.new({
      coins: 10
    }), :test)
    .with(PriseItem.new({
      coins: 10
    }), :test)
    .with(PriseItem.new({
      stars: 10
    }), :test)
    .give!

    @user = User.find(current_user.id)
    expect(@user.acid.real_balance).to eq(10)
    expect(@user.acid.imagine_balance).to eq(20)
    expect(@user.stars).to eq(10)
    expect(@user.coins).to eq(20)
  end
end
