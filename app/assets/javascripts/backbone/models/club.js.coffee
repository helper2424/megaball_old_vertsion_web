class MegaballWeb.Models.Club extends Backbone.Model
  idAttribute: '_id'
  url: '/club'

  initialize: ->
    console.log "Init club with cid: " + this.cid

  level_info: ->
    _.max(
      _.filter(
        window.megaball_config.club_levels,
        (x) => x.from <= @get('level')),
      (x) => x.from)
  
  fetch: ->
    @clear()
    @trigger 'fetch'
    super

  present: -> not _.isEmpty @toJSON()
