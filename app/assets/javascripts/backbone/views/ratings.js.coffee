class MegaballWeb.Views.RatingsEntryView extends MegaballWeb.Views.MasterView
  template: _.template $("#ratings_entry_template").html()

  events:
    'click .stat':'show_stat'
    'click .link':'go_to_link'

  initialize: ->
    @user = @options.user
    @provider_info = @user.provider_info() ? {}
    @type = @options.type
    @me = @options.me
    @render()

  render: ->
    @$el = $ @template {
      place: @user.get 'place'
      name: @user.get('name') + " (#{@user.get_level()} ур.)"
      points: @user.get @type
    }
    @$el.addClass('me') if @me
    @$el.find('.link').hide() unless @provider_info.link?

  show_stat: ->
    statistics = new MegaballWeb.Views.StatisticsView user: @user
    statistics.request_and_show @user

  go_to_link: ->
    window.open @provider_info.link, '_blank'


class MegaballWeb.Views.RatingsView extends MegaballWeb.Views.MasterView
  el: "#rate_block"
  no_data: '<div class="err">Сегодня еще никто не играл!</div>'

  events:
    'click .close':'hide'

  initialize: (@current_user) ->
    super
    console.log("Initialization Ratings view")
    @tabs = new MegaballWeb.Views.MainTabs el: @$el.find('.tabs')
    @tabs.on 'navigate', @context @navigate

    @ratings =
      'daily_rating': new MegaballWeb.Collections.Ratings 'daily_rating'
      'monthly_rating': new MegaballWeb.Collections.Ratings 'monthly_rating'
      #'rating': new MegaballWeb.Collections.Ratings 'rating'
      'goals': new MegaballWeb.Collections.Ratings 'goals'
      'gate_saves': new MegaballWeb.Collections.Ratings 'gate_saves'

    for type, ratings of @ratings
      ratings.on 'sync', @context @render_ratings
      ratings.fetch()

    @userpic = new MegaballWeb.Views.UserPictureView el: @$el.find('.userpic')
    @name = @$el.find('.name-val')
    @points = @$el.find('.points-val')
    @place = @$el.find('.place-val')
    
    @current_user.on 'sync', @context @render
    @render()
    @once 'first navigated', => @navigate 'daily_rating'

  navigted: ->
    @trigger 'first navigated'

  render: ->
    console.log("Render Ratings view")
    @userpic.from_user @current_user
    @name.html @current_user.get 'name'
    @points.html @current_user.get 'rating'
    @place.html @current_user.get 'place'

  render_ratings: (ratings) ->
    el = @$el.find(".content.#{ratings.type}")
    el.html ''

    if ratings.size() == 0
      el.append @no_data

    ratings.sort()
    ratings.each (m) =>
      el.append (new MegaballWeb.Views.RatingsEntryView {
        user: m
        type: ratings.type
        me: m.get('_id') == @current_user.get('_id')
      }).$el

  hide: ->
    @hide_modal()

  navigate: (tab) ->
    @ratings[tab].fetch()
    @current_tab = tab
    @$el.find(".content").hide()
    @$el.find(".content.#{tab}").show()
