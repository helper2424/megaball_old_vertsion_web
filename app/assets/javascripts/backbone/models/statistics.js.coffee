class MegaballWeb.Models.Statistics extends Backbone.Model
  url: '/user/statistics'
  initialize: (uid) ->
    console.log "Init statistics with cid: " + this.cid
    @url += "/#{uid}" if uid?

  get_level: ->
    common_exp = @get 'experience'
    _.filter(window.user_levels, (i) -> i <= common_exp).length
