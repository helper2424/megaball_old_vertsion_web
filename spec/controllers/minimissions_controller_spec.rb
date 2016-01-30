require 'spec_helper'

describe MinimissionsController do

  include DailyMissionHelper

  before :each do
    @dm0 = DailyMission.create params: { wins: 100 }, coins: 10, type: 0
    @dm1 = DailyMission.create params: { goals: 100 }, stars: 1, type: 1
  end

  after :each do
    teardown!
  end

  describe "GET 'index'" do
    it "should not allow unathorized access" do
      stub_user false
      get 'index'
      expect(response).not_to be_success
    end

    it "returns http success" do
      stub_user
      get 'index'
      expect(response).to be_success
    end

    it "should return minimissions" do
      stub_user
      get 'index'
      expect(response).to be_success
      body = JSON.parse response.body

      daily_missions.each do |mission|
        expect(body.index { |x| x['_id'] == mission.id }).not_to be_nil
      end
    end

    it "should return flag whether user completed mission or not" do
      stub_user
      current_user.set(:goals, 0)
      daily_mission_backup!
      current_user.set(:goals, 400)
      check_daily_mission!

      get 'index'
      expect(response).to be_success
      body = JSON.parse response.body

      expect(body.count).to eq(daily_missions.count)

      body.each do |mission|
        case mission['_id']
        when @dm0.id then expect(mission['completed']).to be_false
        when @dm1.id then expect(mission['completed']).to be_true
        else raise Exception.new "Unknown mission id: ", mission['_id']
        end
      end
    end
  end

end
