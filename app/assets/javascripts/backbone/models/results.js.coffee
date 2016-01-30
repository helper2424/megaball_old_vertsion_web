class MegaballWeb.Models.Results extends Backbone.Model
  url: '/user/results'
  initialize: ->
    console.log "Init results with cid: " + this.cid
    @_private = {}

  get_experience_for: (type) ->
    switch type
      when 'victory' then window.user_default.exp_for_win
      when 'draw' then window.user_default.exp_for_draw
      when 'defeat' then window.user_default.exp_for_fail

  get_money_for: (type) ->
    switch type
      when 'victory' then window.user_default.coins_for_win
      when 'draw' then window.user_default.coins_for_draw
      when 'defeat' then window.user_default.coins_for_fail

  get_rating_for: (type) ->
    switch type
      when 'victory' then window.user_default.rating_for_win
      when 'draw' then window.user_default.rating_for_draw
      when 'defeat' then window.user_default.rating_for_fail

  get_score: ->
    @_private.score = _.map(@get('score'), (v, k) -> {id: k, value: v})

  get_type: ->
    myteam = @get 'team'
    score = @get 'score'
    maxscore = _.max score

    draw = true
    draw &= (x == score[0]) for x in score
    draw = !!draw

    switch true
      when draw
        return @_private.type = 'draw'
      when score[myteam] >= maxscore
        return @_private.type = 'victory'
      else
        return @_private.type = 'defeat'
