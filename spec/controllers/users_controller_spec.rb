require 'spec_helper'

describe UsersController do
	context "improve pumping ticks params" do

		it "should improve kick_power" do
			user = stub_user
			post 'improve'
		end

		it "should improve mana_top" do
		end

		it "should improve nitro_speed" do
		end 
	end 
end
