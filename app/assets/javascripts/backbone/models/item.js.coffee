class MegaballWeb.Models.Item extends Backbone.Model
  idAttribute: '_id'
  defaults: {}

  initialize: ->
    console.log "Init item with cid: " + this.cid

class MegaballWeb.Collections.ItemsCollection extends Backbone.Collection
  model: MegaballWeb.Models.Item
  url: window.urls.store_items

  price_factor: 1000000
  coins_factor: 10000
  type_factor:  10

  initialize: ->
    super
    @types = {}
    @type_i = 0

  _comparator: (x) ->
    type = x.get 'type'
    stars = x.get 'stars'
    coins = x.get 'coins'
    unless @types[type]?
      @types[type] = @type_i++
    type = @types[type]
    stars = 0 if stars < 0
    coins = 0 if coins < 0
    Number(x.get 'level_min') * @price_factor +
      Number(stars) * @coins_factor +
      Number(coins) * @type_factor +
      type

  comparator: (left, right) ->
    left_val = @_comparator left
    right_val = @_comparator right
    return -1  if left_val < right_val
    return +1  if left_val > right_val
    return 0
