require 'spec_helper'

describe StoreController do

  before :each do
    @w1 = Weapon.create _id: 1
    @w2 = Weapon.create _id: 2

    @hair = Item.create stars: 10, coins: 10
    @hair.item_contents += [ItemContent.new({ type: 'hair', content: 10 })]
    @hair.save
    @eye = Item.create stars: -1, coins: 10
    @eye.item_contents += [ItemContent.new({ type: 'eye', content: 10 })]
    @eye.save
    @mouth = Item.create stars: 10, coins: -1
    @mouth.item_contents += [ItemContent.new({ type: 'mouth', content: 20 })]
    @mouth.save
    @weapon1 = Item.create
    @weapon1.item_contents += [ItemContent.new({ type: 'weapon', content: @w1.id })]
    @weapon1.save
    @weapon2 = Item.create
    @weapon2.item_contents += [ItemContent.new({ type: 'weapon', content: @w2.id })]
    @weapon2.save
    @inv = Item.create visible: false
    @inv.item_contents += [ItemContent.new({ type: 'eye', content: 20 })]
    @inv.save
  end

  after :each do
    teardown!
    AcidOrder.delete_all
  end

  describe "POST 'buy'" do
    it "should not allow unauthorized access" do
      stub_user false
      post 'buy', item: @hair.id, currency: 'star'
      expect(response).not_to be_success
    end

    it "should return error when item is not specified" do
      stub_user
      post 'buy'
      expect(response).to be_success
      body = JSON.parse response.body

      expect(body).to be_include('error')
      expect(body['error']).to eq('unknown_item')
    end

    it "should return error when currency is not specified" do
      stub_user
      post 'buy', item: @hair.id
      expect(response).to be_success
      body = JSON.parse response.body

      expect(body).to be_include('error')
      expect(body['error']).to eq('unknown_currency')
    end

    it "should return error when user don't have enough coins" do
      stub_user
      acid = current_user.acid
      acid.imagine_balance = 0
      acid.save

      post 'buy', item: @hair.id, currency: 'coin'
      expect(response).to be_success
      body = JSON.parse response.body

      expect(body).to be_include('error')
      expect(body['error']).to eq('not_enough_money')
      expect(body['required']).to eq(@hair.coins)
      expect(body['have']).to eq(acid.imagine_balance)
    end

    it "should return error when user don't have enough stars" do
      stub_user
      acid = current_user.acid
      acid.real_balance = 0
      acid.save

      post 'buy', item: @hair.id, currency: 'star'
      expect(response).to be_success
      body = JSON.parse response.body

      expect(body).to be_include('error')
      expect(body['error']).to eq('not_enough_money')
      expect(body['required']).to eq(@hair.stars)
      expect(body['have']).to eq(acid.real_balance)
    end

    it "should return error when trying to buy for denied currency (stars)" do
      stub_user
      acid = current_user.acid
      acid.real_balance = 100
      acid.imagine_balance = 100
      acid.save

      post 'buy', item: @eye.id, currency: 'star'
      expect(response).to be_success
      body = JSON.parse response.body

      expect(body).to be_include('error')
      expect(body['error']).to eq('denied_currency')
      expect(body['currency']).to eq('star')
    end

    it "should return error when trying to buy for denied currency (coins)" do
      stub_user
      acid = current_user.acid
      acid.real_balance = 100
      acid.imagine_balance = 100
      acid.save

      post 'buy', item: @mouth.id, currency: 'coin'
      expect(response).to be_success
      body = JSON.parse response.body

      expect(body).to be_include('error')
      expect(body['error']).to eq('denied_currency')
      expect(body['currency']).to eq('coin')
    end

    it "should take coins when bought smth" do
      stub_user
      acid = current_user.acid
      acid.real_balance = 100
      acid.imagine_balance = 100
      acid.save

      post 'buy', item: @hair.id, currency: 'coin'
      expect(response).to be_success
      body = JSON.parse response.body

      expect(body).not_to be_include('error')
      expect(current_user.acid.imagine_balance).to eq(90)
      expect(User.find(current_user.id).coins).to eq(90)
    end

    it "should take stars when bought smth" do
      stub_user
      acid = current_user.acid
      acid.real_balance = 100
      acid.imagine_balance = 100
      acid.save

      post 'buy', item: @hair.id, currency: 'star'
      expect(response).to be_success
      body = JSON.parse response.body

      expect(body).not_to be_include('error')
      expect(current_user.acid.real_balance).to eq(90)
      expect(User.find(current_user.id).stars).to eq(90)
    end

    it "should give items when bought smth" do
      stub_user
      acid = current_user.acid
      acid.real_balance = 100
      acid.imagine_balance = 100
      acid.save
      current_user.set(:hair, 0)
      current_user.set(:avail_hair, [0])

      post 'buy', item: @hair.id, currency: 'star'
      expect(response).to be_success
      body = JSON.parse response.body

      expect(body).not_to be_include('error')
      expect(body['item_contents'].count).to eq(1)
      expect(User.find(current_user.id).avail_hair).to be_include(10)
    end

    it "should create acid orders" do
      stub_user
      acid = current_user.acid
      acid.real_balance = 100
      acid.save
      current_user.set(:hair, 0)
      current_user.set(:avail_hair, [0])

      post 'buy', item: @hair.id, currency: 'star'
      expect(response).to be_success
      body = JSON.parse response.body

      expect(body).not_to be_include('error')
      expect(AcidOrder.count).to eq(1)
      expect(AcidOrder.first.acid_user.id).to eq(current_user.id)
      expect(AcidOrder.first.balance_type).to eq(1)
      expect(AcidOrder.first.amount).to eq(@hair.stars)
      expect(AcidOrder.first.product_id).to eq(@hair.id)
      expect(AcidOrder.first.qti).to eq(1)
      expect(AcidOrder.first.balance).to eq(100)
    end

    it "should return error when user already have item" do
      stub_user
      acid = current_user.acid
      acid.real_balance = 100
      acid.imagine_balance = 100
      acid.save
      current_user.set(:hair, 0)
      current_user.set(:avail_hair, [0, 10])

      post 'buy', item: @hair.id, currency: 'star'
      expect(response).to be_success
      body = JSON.parse response.body

      expect(body).to be_include('error')
      expect(body).to be_include('details')
      expect(body['error']).to eq('item_error')
    end

    it "should return error wher user level above level_max" do
      stub_user
      acid = current_user.acid
      acid.real_balance = 100
      acid.save
      current_user.set(:experience, 5000)
      current_user.set(:hair, 0)
      current_user.set(:avail_hair, [0])

      @hair.set(:level_max, 1)
      post 'buy', item: @hair.id, currency: 'star'
      expect(response).to be_success
      body = JSON.parse response.body

      expect(body).to be_include('error')
      expect(body['error']).to eq('incompatible_level')
      expect(body['level_current']).to eq(current_user.level)
      expect(body['level_min']).to eq(@hair.level_min)
      expect(body['level_max']).to eq(@hair.level_max)
    end

    it "should return error wher user level below level_min" do
      stub_user
      acid = current_user.acid
      acid.real_balance = 100
      acid.save
      current_user.set(:experience, 0)
      current_user.set(:hair, 0)
      current_user.set(:avail_hair, [0])

      @hair.set(:level_min, 10)
      post 'buy', item: @hair.id, currency: 'star'
      expect(response).to be_success
      body = JSON.parse response.body

      expect(body).to be_include('error')
      expect(body['error']).to eq('incompatible_level')
      expect(body['level_current']).to eq(current_user.level)
      expect(body['level_min']).to eq(@hair.level_min)
      expect(body['level_max']).to eq(@hair.level_max)
    end
  end

  describe "GET 'items_and_weapons'" do
    it "should not allow unauthorized access" do
      stub_user false
      get 'items_and_weapons'
      expect(response).not_to be_success
    end

    it "should return all visible items" do
      stub_user
      get 'items_and_weapons'
      expect(response).to be_success
      body = JSON.parse response.body

      expect(body).to be_include('items')
      expect(body['items'].count).to eq(5)
    end

    it "should return all weapons that are in item contents" do
      stub_user
      get 'items_and_weapons'
      expect(response).to be_success
      body = JSON.parse response.body

      expect(body).to be_include('weapons')
      expect(body['weapons'][@w1.id.to_s]['_id']).to eq(@w1.id)
      expect(body['weapons'][@w2.id.to_s]['_id']).to eq(@w2.id)
    end

    it "should return true if user already bought" do
      stub_user
      current_user.set(:hair, 0)
      current_user.set(:avail_hair, [0, 10])
      current_user.set(:eye, 0)
      current_user.set(:avail_eye, [0])
      current_user.set(:mouth, 0)
      current_user.set(:avail_mouth, [0, 20])

      uw = UserWeapon.new origin: @w1.id, wasting: false
      uw.user_id = current_user.id
      uw.save

      get 'items_and_weapons'
      expect(response).to be_success
      body = JSON.parse response.body

      body['items'].each do |item|
        case item['_id']
        when @hair.id then expect(item['already_bought']).to be_true
        when @eye.id then expect(item['already_bought']).to be_false
        when @mouth.id then expect(item['already_bought']).to be_true
        when @weapon1.id then expect(item['already_bought']).to be_true
        when @weapon2.id then expect(item['already_bought']).to be_false
        end
      end
    end
  end
end
