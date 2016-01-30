class MegaballWeb.Models.Invite extends Backbone.Model
  defaults: {}

  initialize: ->
    console.log "Init invite with cid: " + this.cid
  url: window.urls.generate_invite