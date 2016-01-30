# encoding: utf-8

class MysqlSchema < ActiveRecord::Migration
  def up
  	
  create_table "club_orders", :force => true do |t|
    t.datetime "date",                                        :null => false
    t.integer  "club_id",                                     :null => false
    t.integer  "balance_type",                                :null => false
    t.decimal  "amount",       :precision => 10, :scale => 2, :null => false
    t.integer  "product_id",                                  :null => false
    t.integer  "product_type",                                :null => false
    t.integer  "qti",                                         :null => false
    t.decimal  "balance",      :precision => 10, :scale => 2, :null => false
  end

  add_index "club_orders", ["club_id"], :name => "fk_club_orders_1_idx"
  add_index "club_orders", ["id"], :name => "id_UNIQUE", :unique => true

  create_table "club_transfer_transactions", :force => true do |t|
    t.datetime "date",                                         :null => false
    t.integer  "transfer_type",                                :null => false
    t.integer  "user_id",                                      :null => false
    t.integer  "club_id",                                      :null => false
    t.decimal  "amount",        :precision => 10, :scale => 2, :null => false
  end

  add_index "club_transfer_transactions", ["club_id"], :name => "fk_club_tt_2_idx"
  add_index "club_transfer_transactions", ["id"], :name => "id_UNIQUE", :unique => true
  add_index "club_transfer_transactions", ["user_id"], :name => "fk_club_tt_1_idx"

  create_table "clubs", :force => true do |t|
    t.integer "real_balance",    :null => false
    t.integer "imagine_balance", :null => false
  end

  add_index "clubs", ["id"], :name => "id_UNIQUE", :unique => true

  create_table "currencies", :force => true do |t|
    t.integer  "gate_id"
    t.integer  "currency",                                     :null => false
    t.string   "name",                                         :null => false
    t.decimal  "exchange_rate", :precision => 10, :scale => 2, :null => false
    t.datetime "date",                                         :null => false
  end

  add_index "currencies", ["gate_id"], :name => "fk_currencies_1_idx"
  add_index "currencies", ["id"], :name => "id_UNIQUE", :unique => true

  create_table "gates", :force => true do |t|
    t.string "name"
  end

  add_index "gates", ["id"], :name => "id_UNIQUE", :unique => true

  create_table "orders", :force => true do |t|
    t.datetime "date",                                        :null => false
    t.integer  "user_id",                                     :null => false
    t.integer  "balance_type",                                :null => false
    t.decimal  "amount",       :precision => 10, :scale => 2, :null => false
    t.integer  "product_id",                                  :null => false
    t.integer  "qti",                                         :null => false
    t.decimal  "balance",      :precision => 10, :scale => 2, :null => false
  end

  add_index "orders", ["id"], :name => "id_UNIQUE", :unique => true
  add_index "orders", ["user_id"], :name => "fk_orders_1_idx"

  create_table "payment_transactions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "currency_id"
    t.datetime "date",                                                :null => false
    t.decimal  "gate_currency_amount", :precision => 10, :scale => 2, :null => false
    t.decimal  "our_currency_amount",  :precision => 10, :scale => 2, :null => false
    t.decimal  "bonus",                :precision => 10, :scale => 2, :null => false
    t.string   "additional"
  end

  add_index "payment_transactions", ["currency_id"], :name => "fk_payment_transactions_2_idx"
  add_index "payment_transactions", ["id"], :name => "id_UNIQUE", :unique => true
  add_index "payment_transactions", ["user_id"], :name => "fk_payment_transactions_1_idx"

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 8
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "users", :force => true do |t|
    t.integer "real_balance",    :null => false
    t.integer "imagine_balance", :null => false
  end

  add_index "users", ["id"], :name => "id_UNIQUE", :unique => true 
  end

  def down
  end
end
