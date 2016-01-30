# encoding: utf-8

class NewsNewPrices < ActiveRecord::Migration
  def up
    nitro_item = Item.where("item_contents.content" => 19, "item_contents.type" => "weapon", visible: true).first
    teleport_item = Item.where("item_contents.content" => 20, "item_contents.type" => "weapon", visible: true).first

    unless teleport_item.nil?
      teleport_item.stars = 1
      teleport_item.coins = 100
      teleport_item.save!
    end

    unless nitro_item.nil?
      nitro_item.stars = 2
      nitro_item.coins = 200
      nitro_item.save!
    end

    trifors_winner_master_item = Item.where("item_contents.type" => "weapon", visible: true).in("item_contents.content" => [12, 17, 25])
    trifors_winner_master_item.each {|x| 
      x.stars = 10
      x.coins = 750
      x.save!
    }

    yellow_blue_item = Item.where("item_contents.type" => "weapon", visible: true).in("item_contents.content" => [31, 32, 33])
    yellow_blue_item.each {|x| 
      x.stars = 3
      x.coins = 450
      x.save!
    }

    diablo_item = Item.where("item_contents.type" => "weapon", visible: true).in("item_contents.content" => [34, 35, 36])
    diablo_item.each {|x| 
      x.stars = 12
      x.coins = 2000
      x.save!
    }

    enter_item = Item.where("item_contents.type" => "weapon", visible: true).in("item_contents.content" => [37, 38, 39])
    enter_item.each {|x| 
      x.stars = 20
      x.coins = 4000
      x.save!
    }

    green_item = Item.where("item_contents.type" => "weapon", visible: true).in("item_contents.content" => [40, 41, 42])
    green_item.each {|x| 
      x.stars = 20
      x.coins = 4000
      x.save!
    }

    elite_item = Item.where("item_contents.type" => "weapon", visible: true).in("item_contents.content" => [28, 29, 30])
    elite_item.each {|x| 
      x.stars = 15
      x.coins = 3500
      x.save!
    }

    energy_item = Item.where("item_contents.type" => "energy", visible: true)
    energy_item.each {|x| 
      x.stars = 1
      x.coins = 250
      it_content = x.item_contents.first
      it_content.content = 100
      x.description = "Выпей, и у тебя снова появятся силы играть. Восстанавливает 100 единиц энергии при покупке."
      x.save! 
    }

    plastic_vip = Item.where(visible: true, "item_contents.content" => 27, "item_contents.type" => "weapon").first
    plastic_vip.coins = 300
    plastic_vip.save!

    wtp_weapon = Weapon.find 6
    wtp_item_default = Item.where(visible: true, "item_contents.content" => wtp_weapon._id, "item_contents.type" => "weapon", "item_contents.is_charge" => false).first
    wtp_item_default.coins = 200
    wtp_item_default.save

    wtp_item_10_charge = Item.where(visible: true, "item_contents.content" => wtp_weapon._id, "item_contents.type" => "weapon", "item_contents.count" => 10,"item_contents.is_charge" => true).first
    wtp_item_10_charge.coins = 100
    wtp_item_10_charge.save!

    wtp_item_100_charge = Item.where(visible: true, "item_contents.content" => wtp_weapon._id, "item_contents.type" => "weapon", "item_contents.count" => 100,"item_contents.is_charge" => true).first
    wtp_item_100_charge.coins = 900
    wtp_item_100_charge.save!
  end

  def down
  end
end
