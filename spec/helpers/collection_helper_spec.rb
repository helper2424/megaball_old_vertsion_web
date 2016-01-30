require 'spec_helper'

describe CollectionHelper do

  before :each do
    @item = Item.create title: "temp"

    @coll1 = Collection.create title: "Hello, World!", coins: 10, stars: 15, items: []
    @item1_1 = CollectionItem.new texture_id: 14
    @item1_2 = CollectionItem.new texture_id: 14
    @coll1.collection_item = [@item1_1, @item1_2]
    @coll1.save

    @coll2 = Collection.create items: [@item.id]
    @item2_1 = CollectionItem.new
    @item2_2 = CollectionItem.new
    @coll2.collection_item = [@item2_1, @item2_2]
    @coll2.save
  end

  after :each do
    teardown!
  end

  it "should return newly added collection items" do
    new_user
    current_user.user_collection.create collection_id: @coll1.id, item_id: @item1_1.id
    current_user.user_collection.create collection_id: @coll1.id, item_id: @item1_2.id
    current_user.save
    refresh_user

    expect(unprocessed_items.count).to eq(1)
    expect(unprocessed_items[0]['title']).to eq(@coll1.title)
    expect(unprocessed_items[0]['collection_item'].count).to eq(2)
    expect(unprocessed_items[0]['collection_item'][0]['texture_id']).to eq(@item1_1.texture_id)
    expect(unprocessed_items[0]['collection_item'][0]['texture_id']).to eq(@item1_2.texture_id)
  end

  it "should mark collections as processed" do
    new_user
    current_user.user_collection.create collection_id: @coll1.id, item_id: @item1_1.id
    current_user.user_collection.create collection_id: @coll1.id, item_id: @item1_2.id
    current_user.save
    refresh_user

    expect(unprocessed_items.count).to eq(1)
    check_collections!
    refresh_user

    expect(unprocessed_items.count).to eq(0)
  end

  it "should not return unfinished collections" do
    new_user
    current_user.user_collection.create collection_id: @coll1.id, item_id: @item1_1.id
    current_user.save
    refresh_user

    result = check_collections!

    expect(result.count).to eq(0)
  end

  it "should return finished newly collections" do
    new_user
    current_user.user_collection.create collection_id: @coll1.id, item_id: @item1_1.id
    current_user.user_collection.create collection_id: @coll1.id, item_id: @item1_2.id
    current_user.save
    refresh_user

    result = check_collections!

    expect(result.count).to eq(1)
    expect(result[0].id).to eq(@coll1.id)
    expect(result[0].coins).to eq(@coll1.coins)
    expect(result[0].stars).to eq(@coll1.stars)
  end

  it "should return several newly finished collections" do
    new_user
    current_user.user_collection.create collection_id: @coll1.id, item_id: @item1_1.id
    current_user.user_collection.create collection_id: @coll1.id, item_id: @item1_2.id
    current_user.user_collection.create collection_id: @coll2.id, item_id: @item2_1.id
    current_user.user_collection.create collection_id: @coll2.id, item_id: @item2_2.id
    current_user.save
    refresh_user

    result = check_collections!

    expect(result.count).to eq(2)
  end

  it "should not return finished collections twice" do
    new_user
    current_user.user_collection.create collection_id: @coll1.id, item_id: @item1_1.id
    current_user.user_collection.create collection_id: @coll1.id, item_id: @item1_2.id
    current_user.save
    refresh_user

    check_collections!
    refresh_user

    current_user.user_collection.create collection_id: @coll2.id, item_id: @item2_1.id
    current_user.user_collection.create collection_id: @coll2.id, item_id: @item2_2.id
    current_user.save
    refresh_user

    result = check_collections!

    expect(result.count).to eq(1)
    expect(result[0].id).to eq(@coll2.id)
  end

  it "should create prise transactions for newly finished collections" do
    new_user
    current_user.user_collection.create collection_id: @coll1.id, item_id: @item1_1.id
    current_user.user_collection.create collection_id: @coll1.id, item_id: @item1_2.id
    current_user.user_collection.create collection_id: @coll2.id, item_id: @item2_1.id
    current_user.user_collection.create collection_id: @coll2.id, item_id: @item2_2.id
    current_user.save
    refresh_user

    check_collections!
    expect(PriseTransaction.where(reason: 'collection').count).to eq(2)

    check_collections!
    expect(PriseTransaction.where(reason: 'collection').count).to eq(2)
  end

end
