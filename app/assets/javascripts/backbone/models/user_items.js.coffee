class MegaballWeb.Models.UserItems extends Backbone.Model
  url: '/user_items'
  initialize: ->
    console.log "Init user item with cid: " + this.cid
