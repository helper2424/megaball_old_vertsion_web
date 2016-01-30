class MegaballWeb.Views.ClubRatingsView extends MegaballWeb.Views.MasterView

  ENTRIES_PER_PAGE = 20

  css_class: 'club_ratings'

  events:
    'click .do-search:not(.inactive)':'dosearch'
    'click .do-clear-search:not(.inactive)':'doclearsearch'
    'click .do-more:not(.inactive)':'more'
    'click .do-join:not(.inactive)':'dojoin'
    'click .owner:not(.inactive)':'show_stats'
    'keypress .searchbox input':'keypress_search'

  initialize: ->
    super
    @club = @options.club
    @controller = @options.controller

    # views
    @search = @$el.find('.searchbox input')
    @list = new MegaballWeb.Views.ScrollView el: @$el.find('.list')
    @inner = @$el.find('.inner-info')
    @logo = new MegaballWeb.Views.ClubPictureView el: @$el.find('.info .logo')
    @title = @$el.find('.info .title')
    @level = @$el.find('.info .level')
    @members = @$el.find('.info .members')
    @owner = @$el.find('.info .owner')
    @rating = @$el.find('.info .rating')
    @place = @$el.find('.info .place')
    @descr = @$el.find('.info .descr')
    @joinbtn = @$el.find('.do-join')
    @noclubyet = @$el.find('.noclubyet')

    # current club
    @cinfo = @$el.find('.cinfo')
    @clogo = new MegaballWeb.Views.ClubPictureView el: @$el.find('.cinfo .logo')
    @cname = @$el.find('.cinfo .name')
    @cplace = @$el.find('.cinfo .place')
    @crating = @$el.find('.cinfo .rating')

    # models
    @tofetch = {}
    @clubs = new MegaballWeb.Collections.Clubs
    @clubs.on 'sync', => MegaballWeb.Views.PopupView.loading_hide()
    @clubs.on 'sync', @context @render
    @clubs.on 'error', => MegaballWeb.Views.PopupView.loading_hide()
    @clubs.on 'fetch', => MegaballWeb.Views.PopupView.loading_show()

  navigated: -> @fetch ENTRIES_PER_PAGE

  fetch: (limit, data={}) ->
    data = $.param _.extend {limit: limit}, data
    @clubs.fetch(data: data)

  render: ->
    list = @list.$().find('.table')
    list.html ''
    i = 0
    @clubs.each (m) =>
      view = new MegaballWeb.Views.ClubEntryView model: m, i: ++i
      view.on 'click', @context @describe
      list.append view.$el
    @list.update()

    if @club.get('_id')?
      @cname.text @club.get 'short_name'
      @cplace.text @club.get 'place'
      @crating.text @club.get('rating')?.format_with_k()
      @clogo.set_logo @club.get 'logo'
      @cinfo.show()
      @noclubyet.hide()
      @joinbtn.addClass 'inactive'
    else
      @cinfo.hide()
      @noclubyet.show()
      @joinbtn.removeClass 'inactive'

  keypress_search: (e) -> @dosearch() if e.which == 13

  dosearch: ->
    text = @search.val()
    if text == ""
      @tofetch = {}
    else
      @tofetch['text'] = text
    @fetch ENTRIES_PER_PAGE, @tofetch

  doclearsearch: ->
    @tofetch = {}
    @search.val ''
    @fetch ENTRIES_PER_PAGE

  more: ->
    @fetch @clubs.size() + ENTRIES_PER_PAGE, @tofetch

  describe: (model) ->
    @model_to_join = model
    @title.text "[#{model.get 'short_name'}] #{model.get 'name'}"
    @level.text model.get 'level'
    @place.text model.get 'place'
    @rating.text model.get 'rating'
    @descr.text model.get 'status_message'
    @members.text model.get 'members_count'
    @owner.text (model.get('owner') ? {name: 'нет владельца'}).name
    @logo.set_logo model.get 'logo'
    @inner.fadeIn('fast')

  dojoin: ->
    MegaballWeb.Views.PopupView.confirm
      text: "Вступить в клуб #{@model_to_join.get 'name'}?"
      ok: =>
        MegaballWeb.Views.PopupView.loading_show()
        $.ajax
          url: "/club/join/#{@model_to_join.get '_id'}"
          method: 'POST'
          success: (data) =>
            MegaballWeb.Views.PopupView.loading_hide()
            if data.error == 'club_is_full'
              MegaballWeb.Views.PopupView.alert 'В клубе нет свободных мест!'
            else switch data.uid?[0]
              when 'already_sent' then MegaballWeb.Views.PopupView.alert 'Вы уже отправили запрос в этот клуб!'
              when 'exceeded' then MegaballWeb.Views.PopupView.alert 'Вы не можете отправить больше запросов!'
              else MegaballWeb.Views.PopupView.alert 'Заявка отправлена!'


  show_stats: -> if @model_to_join.get('owner')?
    user = new MegaballWeb.Models.User @model_to_join.get 'owner'
    view = new MegaballWeb.Views.StatisticsView user: user
    view.request_and_show user


class MegaballWeb.Views.ClubEntryView extends MegaballWeb.Views.MasterView
  template: _.template $("#club_entry_template").html()

  events:
    'click':'click'

  initialize: ->
    @model = @options.model
    @i = @options.i ? 0
    @render()

  render: ->
    @$el = $ @template _.extend @model.toJSON(), {
      i: @i
    }

  click: -> @trigger 'click', @model
