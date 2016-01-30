class MegaballWeb.Models.CheckPassword extends Backbone.Model
  url: '/rooms/check_password'
  initialize: ->
    console.log "Init check_password with cid: " + this.cid
