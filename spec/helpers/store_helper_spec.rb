describe StoreHelper do
  def create item, contents
    item.item_contents += contents
    item.save
    item
  end

  def run x
    expect(x).to eq([])   
  end
  
  before :each do
    @skill_w = Weapon.create _id: 1, action_time: 1, charge: 5, type: 0, action: 0
    @shirt_w = Weapon.create _id: 2, action_time: 1, charge: 5, type: 2, wasting: false
    @other_w = Weapon.create _id: 3, action_time: 1, charge: 5, type: 2, wasting: false

    @hair      = create Item.create, [ItemContent.new({ type: 'hair', content: 10 })]
    @eye       = create Item.create, [ItemContent.new({ type: 'eye', content: 11 })]
    @mouth     = create Item.create, [ItemContent.new({ type: 'mouth', content: 12 })]
    @mixed     = create Item.create, [ItemContent.new({ type: 'hair', content: 5 }),
                                      ItemContent.new({ type: 'eye', content: 6 })]
    @points    = create Item.create, [ItemContent.new({ type: 'reset_points' })]
    @point     = create Item.create, [ItemContent.new({ type: 'point', content: 1 })]
    @energy    = create Item.create, [ItemContent.new({ type: 'energy', content: 100 })]
    @mana      = create Item.create, [ItemContent.new({ type: 'mana', content: 100 })]
    @exclusive = create Item.create, [ItemContent.new({ type: 'exclusive' })]
    @skill     = create Item.create, [ItemContent.new({ type: 'weapon', 
                                                        content: @skill_w.id,
                                                        count: 2 })]
    @shirt     = create Item.create, [ItemContent.new({ type: 'weapon', 
                                                        content: @shirt_w.id,
                                                        count: 1 })]
    @reset     = create Item.create, [ItemContent.new({ type: 'reset' })]
  end

  after :each do
    teardown!
  end

  it "should add hair" do
    new_user
    current_user.set(:hair, 0)
    current_user.set(:avail_hair, [0])
    expect(add_item current_user, @hair).to eq([])
    expect(User.find(current_user.id).avail_hair).to be_include(10)
  end

  it "should add eye" do
    new_user
    current_user.set(:eye, 0)
    current_user.set(:avail_eye, [0])
    expect(add_item current_user, @eye).to eq([])
    expect(User.find(current_user.id).avail_eye).to be_include(11)
  end

  it "should add mouth" do
    new_user
    current_user.set(:mouth, 0)
    current_user.set(:avail_mouth, [0])
    expect(add_item current_user, @mouth).to eq([])
    expect(User.find(current_user.id).avail_mouth).to be_include(12)
  end

  it "should not add same mouth twice" do
    new_user
    current_user.set(:mouth, 0)
    current_user.set(:avail_mouth, [0])
    expect(add_item current_user, @mouth).to eq([])
    expect(add_item(current_user, @mouth)[0][:error]).to eq(:already_bought)
    expect(User.find(current_user.id).avail_mouth).to be_include(12)
  end

  it "should add item with multiple contents" do
    new_user
    current_user.set(:hair, 0)
    current_user.set(:mouth, 0)
    current_user.set(:avail_mouth, [0])
    current_user.set(:avail_hair, [0])
    expect(add_item current_user, @mixed).to eq([])
    expect(User.find(current_user.id).avail_hair).to be_include(5)
    expect(User.find(current_user.id).avail_eye).to be_include(6)
  end

  it "should reset points" do
    new_user
    current_user.set(:points, 0)
    current_user.set(:leg_length, 5)
    current_user.set(:kick_power, 6)
    current_user.set(:move_force, 7)
    expect(add_item current_user, @points).to eq([])
    refresh_user

    expect(User.find(current_user.id).points).to eq(5 + 6 + 7)
    expect(User.find(current_user.id).leg_length).to eq(0)
    expect(User.find(current_user.id).kick_power).to eq(0)
    expect(User.find(current_user.id).move_force).to eq(0)
  end

  it "should add points" do
    new_user
    current_user.set(:points, 0)
    expect(add_item current_user, @point).to eq([])
    expect(User.find(current_user.id).points).to eq(1)
  end

  it "should add energy" do
    new_user
    current_user.set(:energy, 0)
    current_user.set(:energy_max, 110)
    expect(add_item current_user, @energy).to eq([])
    expect(User.find(current_user.id).energy).to eq(100)

    current_user.set(:energy, 0)
    current_user.set(:energy_max, 90)
    expect(add_item current_user, @energy).to eq([])
    expect(User.find(current_user.id).energy).to eq(90)
  end

  it "should add mana" do
    new_user
    current_user.set(:mana, 0)
    current_user.set(:mana_max, 110)
    expect(add_item current_user, @mana).to eq([])
    expect(User.find(current_user.id).mana).to eq(100)

    current_user.set(:mana, 0)
    current_user.set(:mana_max, 90)
    expect(add_item current_user, @mana).to eq([])
    expect(User.find(current_user.id).mana).to eq(90)
  end

  it "should add exclusive" do
    new_user
    current_user.set(:exclusive_count, 0)
    expect(add_item current_user, @exclusive).to eq([])
    expect(User.find(current_user.id).exclusive_count).to eq(1)
  end

  it "should add skills" do
    new_user
    expect(add_item current_user, @skill).to eq([])
    expect(UserWeapon.where(user_id: current_user.id).count).to eq(1)
    uw = UserWeapon.find_by(user_id: current_user.id)
    expect(uw.charge).to eq(10)
    expect(uw.action).to eq(0)
    expect(uw.activate_time).to be > ((Time.now - 1.minute).to_i)
    expect(uw.origin).to eq(@skill_w.id)
  end

  it "should reset accounts" do
    new_user
    10.times do 
      sym = MEGABALL_CONFIG['user_fields_to_reset'].sample.to_sym
      if current_user.send(sym).is_a? Integer
        current_user.set(sym, rand(100))
      end
    end
    UserWeapon.create user_id: current_user.id, origin: @other_w.id

    expect(add_item current_user, @reset).to eq([])
    refresh_user

    template = User.new

    MEGABALL_CONFIG['user_fields_to_reset'].each do |field|
      sym = field.to_sym
      expect(current_user.send(sym)).to eq(template.send(sym))
    end

    MEGABALL_CONFIG["default_weapons"].each do |w_id|
      expect(UserWeapon.find_by(user_id: current_user.id, origin: w_id)).not_to be_nil
    end

    expect(UserWeapon.where(user_id: current_user.id, origin: @other_w.id).count).to eq(0)

    expect(current_user.mana).to eq(current_user.mana_max)
    expect(current_user.energy).to eq(current_user.energy_max)

  end

  it "should charge existing skills" do
    new_user
    expect(add_item current_user, @skill).to eq([])
    expect(add_item current_user, @skill).to eq([])
    expect(UserWeapon.where(user_id: current_user.id).count).to eq(1)
    uw = UserWeapon.find_by(user_id: current_user.id)
    expect(uw.charge).to eq(20)
    expect(uw.action).to eq(0)
    expect(uw.activate_time).to be > ((Time.now - 1.minute).to_i)
    expect(uw.origin).to eq(@skill_w.id)
  end

  it "should return error when trying to add existing weapon" do
    new_user
    expect(add_item current_user, @shirt).to eq([])
    expect(add_item(current_user, @shirt)[0][:error]).to eq(:already_bought)
  end
end
