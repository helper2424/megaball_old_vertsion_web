class MegaballWeb.Collections.Messages extends Backbone.Collection
  url_tpl: '/user/messages'

  initialize: ->
    console.log "Init statistics with cid: " + this.cid

  fetch: (options={}) ->
    @url = @url_tpl unless options.dont_reset?
    super options

  fetch_offset: (offset, type='lt')->
    @url = "#{@url_tpl}?offset=#{offset}&type=#{type}"
    @fetch dont_reset: true

  bound: (type) ->
    id = @[type]((x) -> x.get '_id')
    if not id? or id == Number.POSITIVE_INFINITY or id == Number.NEGATIVE_INFINITY
      return undefined
    id.get('_id')
