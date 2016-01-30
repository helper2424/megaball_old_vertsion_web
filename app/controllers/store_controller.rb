class StoreController < ApplicationController
  include StoreHelper
  include ErrorsHelper

  before_filter :authenticate_user!

  # GET /store/items_and_weapons
  def items_and_weapons
    @items = _items
    weapons = Hash[Weapon.where(:_id.in => 
                                 @items.map { |x| x.item_contents }
                                       .flatten(1)
                                       .reject { |x| x.type != 'weapon' }
                                       .map { |x| x.content })
                         .map { |x| [x._id, x] }]
    render json: {
      items: @items,
      weapons: weapons
    }
  end

  def item
      item = Item.find_by _id: ApplicationHelper.check_int_param(params[:_id])

      render json: item
  end

  def buy
    items = Item.where(_id: params[:item].to_i)
    item = nil
    result = {}
    currency = params[:currency]
    star_currency = currency == 'star'
    coin_currency = currency == 'coin'

    if items.count <= 0
      return render_error :unknown_item, item: params[:item].to_i
    else
      item = items.first
    end

    if !star_currency && !coin_currency
      return render_error :unknown_currency, currency: currency
    end

    if star_currency && item.stars < 0 || \
       coin_currency && item.coins < 0
      return render_error :denied_currency, currency: currency
    end

    level = current_user.level
    if item.level_min > 0 && item.level_min > level || \
       item.level_max > 0 && item.level_max < level
      return render_error :incompatible_level, level_current: level,\
                                               level_min: item.level_min,\
                                               level_max: item.level_max
    end

    AcidUser.transaction do
      acid = current_user.acid
      acid.lock!

      prise_stars = (!item.sales.nil? && item.sales.include?('stars')) \
                  ? item.sales['stars'].to_i : item.stars
      prise_coins = (!item.sales.nil? && item.sales.include?('coins')) \
                  ? item.sales['coins'].to_i : item.coins

      if star_currency && acid.real_balance < prise_stars
        result.merge! error(:not_enough_money, required: item.stars, have: acid.real_balance)
        raise ActiveRecord::Rollback
      end

      if coin_currency && acid.imagine_balance < prise_coins
        result.merge! error(:not_enough_money, required: item.coins, have: acid.imagine_balance)
        raise ActiveRecord::Rollback 
      end

      errors = user_items(current_user).add_item(item)
      if errors.count > 0
        result.merge! error(:item_error, details: errors)
        raise ActiveRecord::Rollback
      end

      info = if star_currency
        temp = acid.real_balance
        acid.real_balance -= prise_stars
        [temp, prise_stars]
      elsif coin_currency
        temp = acid.imagine_balance
        acid.imagine_balance -= prise_coins
        [temp, prise_coins]
      end

      order = AcidOrder.new({ 
        date: Time.now,
        balance_type: (star_currency) ? 1 : (coin_currency) ? 2 : 0,
        amount: info[1],
        balance: info[0],
        qti: 1,
        product_id: item.id,
      })
      order.acid_user = acid

      StatsWorker.perform_for_user(current_user, 'buy', {
        item: "item_#{item.lodash_title}",
        quantity: 1,
        item_id: item.id,
        custom: { currency: currency, price: info[1], category_id: item.category }
      })

      order.save
      acid.save
      result = { 
        item_contents: item.item_contents,
        item: item.lodash_title,
        currency: currency,
        price: info[1]
      }
    end

    render json: result
  end 
 
  private

  def _items
    @user = current_user
    @items = Item.where(visible: true)
    user_weapons = UserWeapon.where(user_id: @user._id).as_json

    @items = @items.map do |item|
      item[:already_bought] = item.item_contents
        .map { |cont|
          case cont.type
          when 'weapon' 
            t = user_weapons.select { |y| y['origin'] == cont.content }.first
            not t.nil? and not t['wasting']
          when 'hair'
            not @user.avail_hair.index{ |y| y == cont.content }.nil?
          when 'eye'
            not @user.avail_eye.index{ |y| y == cont.content }.nil?
          when 'mouth'
            not @user.avail_mouth.index{ |y| y == cont.content }.nil?
          else
            false
          end
        }
        .inject(true) { |x, y| x and y }
      item
    end

    @items
  end

end
