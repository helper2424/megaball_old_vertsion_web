class RouletteItem < PriseItem
  include Mongoid::Timestamps

  alias :super_stars :stars
  alias :super_coins :coins

  field :texture, type: String  

  field :active,              type: Boolean, default: true
  field :chest, 			        type: Boolean, default: false
  field :probability_percent, type: Integer, default: 100
  field :times_a_day,         type: Integer, default: -1

  field :position, type: Integer, default: 0 # 0 - chest, clockwise  

  index active: 1

  scope :active, ->{ where active: true }

  def not_available
    self.times_a_day != -1 and \
      self.times_a_day <= PriseTransaction.today.with_contents([self._id]).count
  end

  def items
    if !chest
      super
    else
      if rand_item_type == :items
        @random_item ||= super.sample
        [@random_item]
      else
        []
      end
    end
  end

  def stars
    if !chest
      super
    else
      (rand_item_type == :stars) ? super : 0
    end
  end

  def coins
    if !chest
      super
    else
      (rand_item_type == :coins) ? super : 0
    end
  end
  
  def as_json opts={}
    if opts.include? :default
      super opts
    else
      json = super opts
      json[:item_objects] = Item.where(:_id.in => self[:items]).as_json
      json[:stars] = self[:stars]
      json[:coins] = self[:coins]
      json
    end
  end

  def as_json_with_random
    json = as_json(defaut: true)
    json[:item_objects] = Item.where(:_id.in => items).as_json
    json[:stars] = stars
    json[:coins] = coins
    json
  end

  def rand_item_type
    if super_stars == 0 && super_coins == 0
      @rand_item_type ||= :items
    else
      if super_stars != 0 && super_coins != 0
        @rand_item_type ||= case rand(3)
                        when 0 then :items
                        when 1 then :stars
                        when 2 then :coins
                        end
      else
        if super_stars == 0
          @rand_item_type ||= case rand(2)
                          when 0 then :items
                          when 1 then :coins
                          end
        end

        if super_coins == 0
          @rand_item_type ||= case rand(2)
                          when 0 then :items
                          when 1 then :stars
                          end
        end
      end
    end
  end
end
