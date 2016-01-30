class MegaballWeb.Models.GamePlay extends Backbone.Model
  idAttribute: '_id'
  defaults: {}

  url: window.urls.current_user

class MegaballWeb.Collections.GamePlaysCollection extends Backbone.Collection
  model: MegaballWeb.Models.GamePlay
  url: '/game_plays'

  to_dict: (model_to_value = (m) -> m.get('name')) ->
    _.object @map (model) -> [model.get('_id'), model_to_value(model)]

