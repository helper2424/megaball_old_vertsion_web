class MegaballWeb.Models.User extends Backbone.Model
  idAttribute: '_id'
  defaults: {}
  url: window.urls.current_user
  level_bounds: window.user_levels

  initialize: ->
    console.log "Init user with cid: " + this.cid

  sign_in_date: -> new Date @get('sign_in_timestamp') * 1000

  been_today: -> Math.round((new Date() - @sign_in_date()) / (1000*60*60*24)) <= 0

  link_template:
    'twitter': _.template "https://twitter.com/account/redirect_by_id?id={{=uid}}"
    'vkontakte': _.template "http://vk.com/id{{=uid}}"
    'odnoklassniki': _.template "http://www.odnoklassniki.ru/profile/{{=uid}}"
    'mailru': (provider) ->
      nick = window.social_service.mailru_user_names[provider.uid]
      nick? ? "http://my.mail.ru/mail/"+nick.toString()+"/" : ""


  validate: (attrs, options)->
    if !attrs.name? or !attrs.name
      return "Empty name"

  has_provider: (uid, provider) ->
    _.find(@get('oauth_providers'), (p) -> p.provider == provider and Number(p.uid) == Number(uid))?

  get_level: ->
    common_exp = @get 'experience'
    _.filter(@level_bounds, (i) -> i <= common_exp).length

  get_level_bound: ->
    @_level = @get_level()
    return '---' if @_level >= @level_bounds.length
    @level_bounds[@_level]

  provider_info: ->
    provider = @get('oauth_providers')[0]
    return undefined unless provider?
    if @link_template[provider.provider]?
      link = @link_template[provider.provider] provider
    _.extend provider, {
      link: link
    }

  get_current_exp_level: ->
    common_exp = @get 'experience'
    result = 0
    prev_bound = 0

    for i in @level_bounds
      if common_exp < i
        level_exp = common_exp - prev_bound

        max_level_exp = i - prev_bound

        if max_level_exp and level_exp
          result = parseInt (level_exp / max_level_exp)*100

        break

      prev_bound = i

    return result

class MegaballWeb.Collections.UsersCollection extends Backbone.Collection
  model: MegaballWeb.Models.User
  url: '/users'

class MegaballWeb.Collections.Ratings extends Backbone.Collection
  url: '/user/ratings/'

  model: MegaballWeb.Models.User

  comparator: (left, right) ->
    left_val = Number left.get 'place'
    right_val = Number right.get 'place'
    return -1  if left_val < right_val
    return +1  if left_val > right_val
    return 0

  initialize: (@type) ->
    console.log "Init ratings with cid: " + this.cid
    @url += @type
