class MegaballWeb.Models.Room extends Backbone.Model
  idAttribute: '_id'
  defaults: {}

  initialize: ->
    console.log "Init room with cid: " + this.cid
  url: window.urls.current_user

class MegaballWeb.Collections.RoomsCollection extends Backbone.Collection
  model: MegaballWeb.Models.Room
  url_template: _.template "/rooms/{{=type}}"

  initialize: ->
    @url = @url_template type: "train"
    @sort_column = '_id'

  set_type: (type="train") -> @url = @url_template type: type

  to_visual_rooms: (game_plays) ->
    collection = new MegaballWeb.Collections.VisualRoomsCollection()
    data = {}
    @each (model) ->
      data = model.toJSON()
      gp = game_plays.get data.game_play
      data['type'] = gp.attributes.name
      collection.add new MegaballWeb.Models.VisualRoom data
    collection

  comparator: (left, right) ->
    return -1  if left.get @sort_column > right.get @sort_column
    return +1  if left.get @sort_column < right.get @sort_column
    return 0

  change_sort: (column) ->
    @sort_column = column
    alert @sort_column
