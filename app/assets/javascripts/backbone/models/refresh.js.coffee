class MegaballWeb.Models.Refresh extends Backbone.Model
  url: '/user/refresh'
  initialize: ->
    console.log "Init refresh with cid: " + this.cid

  fetch: ->
    console.log "REFRESH"
    super
