class MegaballWeb.Collections.Collections extends Backbone.Collection
  url: '/user/collections'
  initialize: ->
    console.log "Init collections with cid: " + this.cid

  get_max_length: -> @max (x) -> x.get('items').length
