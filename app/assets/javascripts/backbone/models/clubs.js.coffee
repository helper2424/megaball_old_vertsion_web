class MegaballWeb.Collections.Clubs extends Backbone.Collection
  url: '/club/all'

  initialize: ->
    console.log "Init clubs with cid: " + this.cid

  fetch: ->
    @trigger 'fetch'
    super
