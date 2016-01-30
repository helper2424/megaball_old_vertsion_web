require 'spec_helper'

describe NewsController do

  before :each do
    @n1 = News.create show: false
    @n2 = News.create show: false
    @n3 = News.create show: true
    @n4 = News.create show: true
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

    it "should return last news" do
      stub_user
      get 'index'
      expect(response).to be_success
      body = JSON.parse response.body

      expect(body['_id']).to eq(@n4.id)
      expect(body['no_news']).to be_false
    end

    it "should return true when user haven't seen news yet" do
      stub_user
      current_user.set(:last_shown_news, @n2.id)
      get 'index'
      expect(response).to be_success
      body = JSON.parse response.body

      expect(body['need_to_show']).to be_true
      expect(body['no_news']).to be_false
    end

    it "shouldn't return true when user already seen news" do
      stub_user
      current_user.set(:last_shown_news, @n4.id)
      get 'index'
      expect(response).to be_success
      body = JSON.parse response.body

      expect(body['need_to_show']).not_to be_true
      expect(body['no_news']).to be_false
    end

    it "should return false if there's no news" do
      News.delete_all

      stub_user
      get 'index'
      expect(response).to be_success
      body = JSON.parse response.body

      expect(body['need_to_show']).not_to be_true
      expect(body['no_news']).to be_true
    end

    it "should return false if all news has show: false" do
      News.all.set(:show, false)

      stub_user
      get 'index'
      expect(response).to be_success
      body = JSON.parse response.body

      expect(body['need_to_show']).not_to be_true
      expect(body['no_news']).to be_true
    end
  end

end
