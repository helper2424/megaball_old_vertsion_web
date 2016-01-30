require 'spec_helper'

describe BankController do

  include IframeHelper

  describe "GET 'index'" do

    before :each do
      check_provider
      
      robokassa = AcidGate.create name: 'robokassa'

      currency = AcidCurrency.new currency: 1, acid_gate: robokassa, name: 'star', exchange_rate: 6, date: DateTime.now
      currency.acid_gate = robokassa
      currency.save!

      currency = AcidCurrency.new currency: 2, acid_gate: robokassa, name: 'coin', exchange_rate: BigDecimal.new('55'), date: DateTime.now
      currency.acid_gate = robokassa
      currency.save!

      @payment = MEGABALL_CONFIG['payment'][@current_provider || 'default']
      @currency = AcidCurrency.current @payment['gate']
    end

    after :each do
      teardown!
    end

    it "should not allow unathorized access" do
      stub_user false
      get 'index'
      expect(response).not_to be_success
    end


    it "should return coin offers" do
      stub_user
      get 'index'
      expect(response).to be_success
      body = JSON.parse response.body

      expect(body).to be_include('coins')
      coins = body['coins']
      
      coins.each do |coin|
        value  = [coin['amount'], coin['bonus']]
        expect(@payment['imagine']).to be_include(value)
        expect(coin['price']).to eq(AcidCurrency.calculate_price(coin['amount'], @currency[:imagine]))
      end
    end

    it "should return star offers" do
      stub_user
      get 'index'
      expect(response).to be_success
      body = JSON.parse response.body

      expect(body).to be_include('stars')
      stars = body['stars']
      
      stars.each do |star|
        value  = [star['amount'], star['bonus']]
        expect(@payment['real']).to be_include(value)
        expect(star['price']).to eq(AcidCurrency.calculate_price(star['amount'], @currency[:real]))
      end
    end

    it "should return coin conversion rates" do
      stub_user
      get 'index'
      expect(response).to be_success
      body = JSON.parse response.body

      expect(body).to be_include('exchange_rate')
      rate = body['exchange_rate']
      expect(rate).to be_include('coins')
      expect(rate['coins'].to_f).to eq(@currency[:imagine].exchange_rate.to_f)
    end

    it "should return star conversion rates" do
      stub_user
      get 'index'
      expect(response).to be_success
      body = JSON.parse response.body

      expect(body).to be_include('exchange_rate')
      rate = body['exchange_rate']
      expect(rate).to be_include('stars')
      expect(rate['stars'].to_f).to eq(@currency[:real].exchange_rate.to_f)
    end
  end

end
