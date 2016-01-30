#= require ./user

class MegaballWeb.Collections.ClubRequests extends Backbone.Collection
  url: '/club/requests'
  model: MegaballWeb.Models.User

  initialize: ->
    console.log "Init club request with cid: " + this.cid
