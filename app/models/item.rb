class Item
  include Mongoid::Document

  CHEST = 8

  auto_increment :_id

  field :title, localize: true, default: ""
  field :description, localize: true, default: ""
  field :texture, type: String, default: ""
  field :stars, type: Integer, default: 1
  field :coins, type: Integer, default: 10
  field :level_min, type: Integer, default: 0
  field :level_max, type: Integer, default: 0
  field :visible, type: Boolean, default: true

  field :light_new, type: Boolean, default: false

  # 1 - bottles
  # 2 - skills
  # 3 - clothes // shirt actually
  # 4 - sets
  # 5 - faces
  # 6 - shoes
  # 7 - shorts
  field :category, type: Integer, default: 0
  field :sales, type: Hash, default: nil
  field :random, type: Boolean, default: false

  index :visible => 1, 
    'item_contents.is_charge' => 1,
    'item_contents.chargable' => 1,
    'item_contents.content' => 1,
    'item_contents.type' => 1

  embeds_many :item_contents
  accepts_nested_attributes_for :item_contents, allow_destroy: true

  def lodash_title
    (title || "").to_s.gsub(/\s/, '_').downcase
  end

  def randomize
    if UserDefault.first.chest_exclusive
      UserDefault.first.set :chest_exclusive, false
      @random_item = ItemContent.new type: 'exclusive'
    else
      sum = self.item_contents.inject(0) { |n, x| n + x.chance }
      num = rand sum
      weight = 0
      self.item_contents.each do |cont|
        weight += cont.chance
        if weight >= num
          @random_item = cont
          break
        end
      end
    end
    @random_item
  end

  def each_contents(&block)
    if self.random
      if @random_item.nil?
        block.call randomize
      else
        block.call @random_item
      end
    else
      self.item_contents.each { |c| block.call c }
    end
  end
end
