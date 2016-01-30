require 'spec_helper'

describe RouletteHelper do
  it "should add tickets if day changed" do
    new_user
    current_user.set(:last_roulette_ticket_given, Time.now - 1.day)
    current_user.set(:roulette_tickets, 0)
    check_roulette_tickets!
    expect(current_user.roulette_tickets).to eq(1)
  end

  it "shouldn't give tickets if day didn't change" do
    new_user
    current_user.set(:last_roulette_ticket_given, Time.now)
    current_user.set(:roulette_tickets, 0)
    check_roulette_tickets!
    expect(current_user.roulette_tickets).to eq(0)
  end
end
