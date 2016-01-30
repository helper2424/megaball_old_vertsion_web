require 'spec_helper'

describe RouletteController do
  before :each do
    RouletteItem.create texture_id: 1, coins: 10
    RouletteItem.create texture_id: 1, coins: 20
    RouletteItem.create texture_id: 1, coins: 30
    RouletteItem.create texture_id: 1, coins: 40
  end

  after :each do
    teardown!
  end

  it "should return error when there's no tickets" do
    stub_user
    current_user.set(:roulette_tickets, 0)
    get 'roll'

    body = JSON.parse response.body
    expect(body['error']).to eq('no_tickets')
    expect(PriseTransaction.with_reason(:roulette).count).to eq(0)
  end

  it "should roll random prise and spend tickets" do
    stub_user
    current_user.set(:roulette_tickets, 1)

    get 'roll'

    body = JSON.parse response.body
    expect(body).not_to be_include('error')
    expect(PriseTransaction.with_reason(:roulette).count).to eq(1)
    expect(current_user.roulette_tickets).to eq(0)
  end
end
