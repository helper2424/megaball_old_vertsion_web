# -*- encoding: utf-8 -*-

require Rails.root.join('lib', 'refresh_user_action.rb')

module RailsAdmin
  module Config
    module Actions
      class RefreshUser < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)
      end
    end
  end
end

RailsAdmin.config do |config|

  config.actions do
    dashboard
    index
    new
 
    refresh_user do
      visible do 
        bindings[:abstract_model].model.to_s == "User"
      end
    end
 
    show
    edit
    delete
  end

  config.authorize_with :cancan, AdminAbility

  # models with integer _id
  %W(
    Ball
    GameEvent
    GamePlay
    Map
    TeamGameResult
    UserGameResult
    Weapon
  ).each do |model|
    config.model model do
      configure :_id, :integer do label 'ID' end
    end
  end

  config.model 'Item' do
    configure :category, :enum do 
      enum do
        [
          ['Bottles', 1],
          ['Skills', 2],
          ['Clothes', 3],
          ['Sets', 4],
          ['Faces', 5],
          ['Shoes', 6],
          ['Shorts', 7]
        ]
      end
    end
  end

end
