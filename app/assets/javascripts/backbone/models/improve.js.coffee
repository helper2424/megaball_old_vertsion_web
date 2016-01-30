class MegaballWeb.Models.Improve extends Backbone.Model
  initialize: (stat) ->
    @url = "/user/improve/#{stat}"
    console.log "Init improve with cid: " + @cid
