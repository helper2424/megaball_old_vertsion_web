class MegaballWeb.Models.VisualRoom extends Backbone.Model
  idAttribute: '_id'
  defaults: {}

  initialize: ->
    console.log "Init visual room with cid: " + this.cid
  url: window.urls.current_user

class MegaballWeb.Collections.VisualRoomsCollection extends Backbone.Collection
  model: MegaballWeb.Models.VisualRoom
  url: window.urls.rooms_train

  initialize: -> @sort_column = '_id'

  comparator: (collection) -> collection.get @sort_column
  change_sort: (column) -> 
    @sort_column = column
