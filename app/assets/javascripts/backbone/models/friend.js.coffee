class MegaballWeb.Models.Friend extends Backbone.Model
  defaults: {}
  initialize: ->
    console.log "Init friend with cid: " + this.cid

class MegaballWeb.Collections.FriendsCollection extends Backbone.Collection
  model: MegaballWeb.Models.Friend

  range_index: (range)->
    result = []

    for i in range 
      el = this.at(i)

      if el
        result.push(el.toJSON())

    result

  comparator: (model) -> 
    m = model.get('user')
    if m? then m.get_level()
    else null

  merge_users: (users, provider='') ->
    context = @
    coll = new MegaballWeb.Collections.FriendsCollection()
    @each (model) ->
      data = model.toJSON()
      data['user'] = users.find (u) -> u.has_provider model.id, provider
      coll.add new MegaballWeb.Models.Friend data 
    coll
