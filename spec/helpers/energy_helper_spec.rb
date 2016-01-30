require 'spec_helper'

describe EnergyHelper do
  after :each do
    Timecop.return
  end

  # it "should restore energy" do
  #   new_user
  #   check_energy!
  #   current_user.set(:energy, 0)
  #   Timecop.travel(Time.now + 4.minutes)
  #   check_energy!
  #   expect(current_user.energy).to eq((current_user.energy_restore_factor * 4).round)
  # end

  # it "should restore extended energy" do
  #   new_user
  #   check_energy!
  #   current_user.set(:energy, 0)
  # end


  # level 1
  # 0 energy
  it "should restore 0 energy with 50 user energy for level 1" do
    expect(calc_energy(0, 50, 1)).to eq(0)
  end

  it "should restore 0 energy with 100 user energy for level 1" do
    expect(calc_energy(0, 100, 1)).to eq(0)
  end

  it "should restore 0 energy with 175 user energy for level 1" do
    expect(calc_energy(0, 175, 1)).to eq(0)
  end
 
  it "should restore 0 energy with 1000 user energy for level 1" do
    expect(calc_energy(0, 1000, 1)).to eq(0)
  end

  #1 energy 
  it "should restore 1 energy with 50 user energy for level 1" do
    expect(calc_energy(0.5, 50, 1)).to eq(1)
  end

  it "should restore 1 energy with 100 user energy for level 1" do
    expect(calc_energy(0.75, 100, 1)).to eq(1)
  end

  it "should restore 1 energy with 175 user energy for level 1" do
    expect(calc_energy(1.25, 175, 1)).to eq(1)
  end

  it "should restore 1 energy with 1000 user energy for level 1" do
    expect(calc_energy(2.5, 1000, 1)).to eq(1)
  end

  # 60 energy
  it "should restore 60 energy with 50 user energy for level 1" do
    expect(calc_energy(32.5, 50, 1)).to eq(60)
  end

  it "should restore 60 energy with 100 user energy for level 1" do
    expect(calc_energy(50, 100, 1)).to eq(60)
  end

  it "should restore 60 energy with 175 user energy for level 1" do
    expect(calc_energy(75, 175, 1)).to eq(60)
  end

  it "should restore 60 energy with 1000 user energy for level 1" do
    expect(calc_energy(150, 1000, 1)).to eq(60)
  end

  # 80 energy
  it "should restore 80 energy with 50 user energy for level 1" do
    expect(calc_energy(47.5, 50, 1)).to eq(80)
  end

  it "should restore 80 energy with 100 user energy for level 1" do
    expect(calc_energy(75, 100, 1)).to eq(80)
  end

  it "should restore 80 energy with 175 user energy for level 1" do
    expect(calc_energy(100, 175, 1)).to eq(80)
  end

  it "should restore 80 energy with 1000 user energy for level 1" do
    expect(calc_energy(200, 1000, 1)).to eq(80)
  end

  # 100 energy
  it "should restore 100 energy with 50 user energy for level 1" do
    expect(calc_energy(62.5, 50, 1)).to eq(100)
  end

  it "should restore 100 energy with 100 user energy for level 1" do
    expect(calc_energy(100, 100, 1)).to eq(100)
  end

  it "should restore 100 energy with 175 user energy for level 1" do
    expect(calc_energy(125, 175, 1)).to eq(100)
  end

  it "should restore 100 energy with 1000 user energy for level 1" do
    expect(calc_energy(250, 1000, 1)).to eq(100)
  end

  # user energy 0
  it "should restore 0 energy with 0 user energy for level 1" do
    expect(calc_energy(0, 0, 1)).to eq(0)
  end

  it "should restore 1 energy with 0 user energy for level 1" do
    expect(calc_energy(0.5, 0, 1)).to eq(1)
  end

  it "should restore 50 energy with 0 user energy for level 1" do
    expect(calc_energy(25, 0, 1)).to eq(50)
  end

  it "should restore 100 energy with 0 user energy for level 1" do
    expect(calc_energy(50, 0, 1)).to eq(100)
  end

  # level 5
  # 0 energy
  it "should restore 0 energy with 50 user energy for level 6" do
    expect(calc_energy(0, 50, 6)).to eq(0)
  end

  it "should restore 0 energy with 100 user energy for level 6" do
    expect(calc_energy(0, 100, 6)).to eq(0)
  end

  it "should restore 0 energy with 175 user energy for level 6" do
    expect(calc_energy(0, 175, 6)).to eq(0)
  end
 
  it "should restore 0 energy with 1000 user energy for level 6" do
    expect(calc_energy(0, 1000, 6)).to eq(0)
  end

  #1 energy 
  it "should restore 1 energy with 50 user energy for level 6" do
    expect(calc_energy(1, 50, 6)).to eq(1)
  end

  it "should restore 1 energy with 100 user energy for level 6" do
    expect(calc_energy(1.5, 100, 6)).to eq(1)
  end

  it "should restore 1 energy with 175 user energy for level 6" do
    expect(calc_energy(2.5, 175, 6)).to eq(1)
  end

  it "should restore 1 energy with 1000 user energy for level 6" do
    expect(calc_energy(5, 1000, 6)).to eq(1)
  end

  # 60 energy
  it "should restore 60 energy with 50 user energy for level 6" do
    expect(calc_energy(65, 50, 6)).to eq(60)
  end

  it "should restore 60 energy with 100 user energy for level 6" do
    expect(calc_energy(100, 100, 6)).to eq(60)
  end

  it "should restore 60 energy with 175 user energy for level 5" do
    expect(calc_energy(150, 175, 6)).to eq(60)
  end

  it "should restore 60 energy with 1000 user energy for level 6" do
    expect(calc_energy(300, 1000, 6)).to eq(60)
  end

  # 80 energy
  it "should restore 80 energy with 50 user energy for level 6" do
    expect(calc_energy(95, 50, 6)).to eq(80)
  end

  it "should restore 80 energy with 100 user energy for level 6" do
    expect(calc_energy(150, 100, 6)).to eq(80)
  end

  it "should restore 80 energy with 175 user energy for level 6" do
    expect(calc_energy(200, 175, 6)).to eq(80)
  end

  it "should restore 80 energy with 1000 user energy for level 6" do
    expect(calc_energy(400, 1000, 6)).to eq(80)
  end

  # 100 energy
  it "should restore 100 energy with 50 user energy for level 6" do
    expect(calc_energy(125, 50, 6)).to eq(100)
  end

  it "should restore 100 energy with 100 user energy for level 6" do
    expect(calc_energy(200, 100, 6)).to eq(100)
  end

  it "should restore 100 energy with 175 user energy for level 6" do
    expect(calc_energy(250, 175, 6)).to eq(100)
  end

  it "should restore 100 energy with 1000 user energy for level 6" do
    expect(calc_energy(500, 1000, 6)).to eq(100)
  end

  # user energy 0
  it "should restore 0 energy with 0 user energy for level 6" do
    expect(calc_energy(0, 0, 6)).to eq(0)
  end

  it "should restore 1 energy with 0 user energy for level 6" do
    expect(calc_energy(1, 0, 6)).to eq(1)
  end

  it "should restore 50 energy with 0 user energy for level 6" do
    expect(calc_energy(50, 0, 6)).to eq(50)
  end

  it "should restore 100 energy with 0 user energy for level 6" do
    expect(calc_energy(100, 0, 6)).to eq(100)
  end
end
