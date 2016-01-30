class PriseBuilder
  include StoreHelper

  def initialize user
    @models = []
    @user = user
  end

  def with model, reason
    @models << [model, reason]
    self
  end 

  def with_hash hash, reason
    with PriseItem.new(hash), reason
  end

  def give!
    raise Exception.new :no_user_sepcified if @user.nil?

    errors = []
    @models.each do |model, reason|
      PriseTransaction.create(user_id: @user.id,
                              content: model.id,
                              reason: reason,
                              items: model.items,
                              coins: model.coins,
                              stars: model.stars)

      stats_reason = "prise_for_#{reason}"

      if !model.stars.nil? && model.stars != 0
        StatsWorker.perform_for_user(@user, stats_reason, {
          item: 'stars',
          quantity: model.stars,
        })
      end

      if !model.coins.nil? && model.coins != 0
        StatsWorker.perform_for_user(@user, stats_reason, {
          item: 'coins',
          quantity: model.coins,
        })
      end

      unless model.items.nil?
        items = user_items(@user)
        errors += Item.where(:_id.in => model.items).map do |item|
          e = items.add_item item
          if e.count == 0
            StatsWorker.perform_for_user(@user, stats_reason, {
              item: "item_#{item.lodash_title}",
              quantity: 1,
            })
          end
          e
        end.flatten
      end

      if !model.coins.nil? && model.coins != 0
        @user.acid.contribute_currency model.coins, :imagine, reason
      end

      if !model.stars.nil? && model.stars != 0
        @user.acid.contribute_currency model.stars, :real, reason
      end
    end

    errors
  end
end

module PriseHelper
  def format_prises models
    models.map { |m| format_prise m }
  end

  def format_prise model
    json = model.as_json
    unless json['items'].nil?
      json['items'] = Item.where(:_id.in => json['items'])
                          .entries
                          .group_by { |i| i._id }
                          .values
                          .map do |items|
                            item = items[0].as_json
                            item['count'] = items.count
                            item
                          end
    end
    json
  end

  def prise_for user
    PriseBuilder.new user
  end
end
