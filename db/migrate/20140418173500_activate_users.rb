# encoding: utf-8

class ActivateUsers < ActiveRecord::Migration
  def up
    User.unscoped.set(:active, true)
    User.unscoped.set(:mana_max, 250)
  end

  def down
    User.unscoped.set(:active, false)
  end
end
