class MegaballWeb.Collections.Achievements extends Backbone.Collection
  url: '/user/achievements'
  initialize: ->
    console.log "Init achievements with cid: " + this.cid
