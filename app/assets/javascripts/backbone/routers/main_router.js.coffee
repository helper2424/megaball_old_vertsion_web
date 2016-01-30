class MegaballWeb.Routers.MainsRouter extends Backbone.Router
  loading_el: $ '#loading'
  disconnect_el: $ '#disconnect'
  menus_el: $ '#header'

  routes:
    "":"init_unity"
    "init_unity":"init_unity"
    "main":"main"
    "play":"play"
    "train":"train"
    "store":"store"
    "store/:tab":"store"
    "rate(/:tab)":"rate"
    "bank(/:tab)":"bank"
    "progress(/:tab)(/:id)":"progress"
    "club":"club"
    "profile":"profile"
    "settings":"settings"
    "user_control":"user_control"
    "mail":"mail"
    "results":"sresults"
    "new_level":"new_level"
    "news":"news"
    "*other":"main"

  timeout: 10000

  initialize: (@current_user, @game_plays) ->
    console.log("Main router initialization")
    context = @

    @minimize_check = false
    @results_id = undefined
    @modal_counter = 0
    @plugin_status_update_counter = 2

    @refresh = new MegaballWeb.Models.Refresh
    @results = new MegaballWeb.Models.Results
    @club    = new MegaballWeb.Models.Club

    window.main_tabs = @main_tabs = new MegaballWeb.Views.MainTabs el: $ '#main_tabs'
    @main_tabs.on 'navigate', (e) => @navigate e, true

    @init_settings() # needed for settings sync
    @init_mail() # needed for receiving mail
    @init_news()
    @init_header()
    @menus_el.hide()

    window.u_loaded = _.bind(@loaded, @)
    window.u_group_disconnect = _.bind(@disconnect, @)
    window.u_connected = _.bind(@connect, @)
    window.u_minimize = @context @on_unity_minimize
    
    @current_user.on 'sync', @context @on_user_sync
    @current_user.once 'sync', @context @plugin_status_update
    @refresh.on 'sync', @context @on_refresh
    @results.on 'sync', @context @on_results

    @results.fetch()
    @refresh.fetch()
    @game_plays.fetch()

  context: (cb) -> _.bind cb, @

  entered_game: ->
    @trigger 'entered_game'
    @stop_update_online()
    @stop_update_user()

  leave_game: ->
    @trigger 'leaved_game'
    @update_online()
    @update_user()
    @refresh.fetch()

  loaded: ->
    # mega shit 1
    if window.megaball_config.first_time && window.megaball_config.first_game && !@popups_showed
      @popups_showed = true
      if window.megaball_config.show_news
        @news()
      if window.megaball_config.days_in_row > 0
        @daily_bonus window.megaball_config.days_in_row
      if window.megaball_config.first_game
        @welcome()

    return if @dont_load?
    @dont_load = true
    @update_online()
    @menus_el.show()
    @navigate 'main', true
    if not window.megaball_config.fresh_man_tour_finished and
     window.social_service.show_freshman_bar()
      @fresh_man = new MegaballWeb.Views.FreshManView current_user: @current_user, router: this

    # mega shit 2
    if !window.megaball_config.first_time
      if window.megaball_config.show_news
        @news()
      if window.megaball_config.days_in_row > 0
        @daily_bonus window.megaball_config.days_in_row

    if window.megaball_config.first_time
      window.megaball_config.first_game = true

    unless @current_user.get('have_seen_menu')
      @current_user.save {
        have_seen_menu: true
      }, patch: true

  update_online: ->
    @stop_update_online()
    @update_online_id = setInterval (=>
      if window.friend_uids?
        console.log 'Friends online request'
        window.u_group_action 8, window.friend_uids
    ), 10000

  stop_update_online: ->
    clearInterval @update_online_id if @update_online_id?

  update_user: ->
    @stop_update_user()
    @update_user_id = setInterval @context(@user_fetch), 60 * 1000

  stop_update_user: ->
    clearInterval @update_user_id if @update_user_id?

  user_fetch: -> @current_user.fetch()
  disconnect: -> @disconnect_el.fadeIn "slow"
  connect: -> @disconnect_el.fadeOut "slow"

  on_user_sync: ->
    @new_level()
    temp = @results.get('game_result_id') ? 0
    if @minimize_check
      @minimize_check = false
      route = '/main'
      if not @current_user.get('in_game') and @current_user.get('group_id') != 0
        window.u_group_action 6, [@current_user.get '_id']
      @navigate route, true
    @results_id = temp

  on_refresh: ->
    @current_user.fetch()
    if @refresh.get('pending_achievements')?
      @new_achievement()

  on_results: ->
    @current_user.fetch()

  bank: (tab) ->
    MegaballWeb.currencies.navigate switch tab
      when 'stars' then 'star'
      when 'coins' then 'coin'

  on_unity_minimize: ->
    @minimize_check = true
    @results.fetch()

  main: ->
    unless @main_view?
      #@main_view = new MegaballWeb.Views.MainView @current_user, @game_plays, this
      @main_view = new MegaballWeb.Views.UnityView scene: 'main'
    window.u_minimize_unity()
    @do_process 'main', @main_view

  play: -> @do_process 'play', @play_view

  load_resources: (cb) ->
    loads = []
    i = 0

    loaded = false
    call = ->
      if not loaded and cb?
        cb()
        loaded = true

    setTimeout call, @timeout
    fire = -> --i; call() if i <= 0

    for res in window.resources
      image = $ new Image
      image.res = res
      image.load fire
      image.attr 'src', res
      ++i

  plugin_status_update: ->
    @plugin_status_update_counter -= 1
    if @plugin_status_update_counter <= 0 and @user?.get?('plugin_status') != @plugin_status
      @current_user.save {
        plugin_status: @plugin_status
      }, patch: true

  init_unity: ->
    console.log("Init unity web player")

    unless @play_view?
      @play_view = new MegaballWeb.Views.PlayView
      @play_view.router = this
      @play_view.$el.css {
        width: window.unityConfig.width,
        height: window.unityConfig.height
      }

    unless @unityObject?

      if !@current_block? or @current_block != @play_view.el
        @switch_blocks(@current_block, @play_view.el)
        @current_block = @play_view.el

      window.unityObject = @unityObject = new UnityObject2 window.unityConfig
          
      @unityObject.observeProgress (progress) =>

        @plugin_status = progress.pluginStatus
        @plugin_status_update()

        switch (progress.pluginStatus)

          when "broken"
            $('.broken').find("a").click (e) =>
              e.stopPropagation()
              e.preventDefault()
              @unityObject.installPlugin()
              false
            $(".missing").show()

            popup_func = =>
              popup = new MegaballWeb.Views.InstallUnityView text: "Поврежден Unity"
              popup.on 'any', => @unityObject.installPlugin();popup.dispose()
              popup.show()

            popup_func()

          when "missing"
            if window.env != 'release' and window.env != 'production'
              @loaded()
              return

            $(".missing").find("a").click (e) =>
              e.stopPropagation()
              e.preventDefault()
              @unityObject.installPlugin()
              false
            $(".missing").show()

            popup_func = =>
              popup = new MegaballWeb.Views.InstallUnityView text: "Не установлен Unity"
              popup.on 'any', => @unityObject.installPlugin();popup.dispose()
              popup.show()

            popup_func()

          #when "installed"

          #when "first"

          when "unsupported"
            if window.env != 'release'
              window.u_loaded()
            else
              popup_text = 'Ваша операционная система или браузер не поддерживает Unity Web Player!'

              popup_func = ->
                popup = new MegaballWeb.Views.PopupView.alert(popup_text)
                popup.on 'any', popup_func

              popup_func()
              
            break
          else $(".some_error").show()
          
      @unityObject.initPlugin @play_view.$el.find('.unity-wrapper')[0], window.unityBinUrl

  train: ->
    return if $(".tab[data-route=train]").hasClass("inactive")
    unless @train_view?
      @train_view = new MegaballWeb.Views.TrainView @current_user, @game_plays
      @train_view.router = this

    @do_process 'train', @train_view

  store: (tab) ->
    unless @store_view?
      @store_view = new MegaballWeb.Views.UnityStoreView
    @do_process 'store', @store_view, false, tab

  old_store: (tab)->
    unless @store_view?
      @store_view = new MegaballWeb.Views.StoreView @current_user, @refresh
      @store_view.router = @

    @store_view.navigate tab if tab?
    @do_process 'store', @store_view

  arena: ->


  rate: ->
    unless @rate_view?
      @rate_view = new MegaballWeb.Views.RatingsView @current_user
      @rate_view.router = this

    if @check_unity()
      @show_modal @rate_view

  welcome: ->
    unless @welcome_view?
      @welcome_view = new MegaballWeb.Views.WelcomeView @current_user
      @welcome_view.router = this

    if @check_unity()
      @show_modal @welcome_view

  user_control: ->
    unless @user_control_view?
      @user_control_view = new MegaballWeb.Views.UserControlView @current_user
      @user_control_view.router = this

    if @check_unity()
      @show_modal @user_control_view

  progress: (tab, id) ->
    unless @progress_view?
      @progress_view = new MegaballWeb.Views.ProgressView @current_user, @refresh
      @progress_view.router = this

    @do_process 'progress', @progress_view
    @progress_view.navigate {tab: tab, id: id} if tab?

  club: ->
    unless @club_view?
      @club_view = new MegaballWeb.Views.ClubControllerView @club, @current_user, this
      @club_view.router = this

    @do_process 'club', @club_view

  profile: ->
    unless @profile_view?
      @profile_view = new MegaballWeb.Views.ProfileView @current_user
      @profile_view.router = this

    @do_process 'profile', @profile_view

  new_level: ->
    level = @current_user.get_level()

    if not @prev_level?
      @prev_level = level
      return false
    else if @prev_level >= level
      return false

    @prev_level = level

    unless @new_level_view?
      @new_level_view = new MegaballWeb.Views.NewLevelView @current_user
      @new_level_view.router = this

    if @check_unity()
      @show_modal @new_level_view

  club_chat: ->
    unless @club_chat_view?
      @club_chat_view = new MegaballWeb.Views.ClubChat {
        club: @club
        current_user: @current_user
      }
      @club_chat_view.router = this

    if @check_unity()
      @show_modal @club_chat_view

  gift: (prise) ->
    unless @gift_view?
      @gift_view = new MegaballWeb.Views.GiftView @refresh, @current_user
      @gift_view.router = this

    if @check_unity()
      @show_modal @gift_view, prise

  daily_bonus: (day) ->
    unless @daily_bonus_view?
      @daily_bonus_view = new MegaballWeb.Views.DailyBonusView @refresh, @current_user
      @daily_bonus_view.router = this

    if @check_unity()
      @show_modal @daily_bonus_view, day

  new_achievement: ->
    ach = @refresh.get('pending_achievements')
    return if not ach? or not ach
    @refresh.set('pending_achievements', null)

    unless @new_achievement_view?
      @new_achievement_view = new MegaballWeb.Views.NewAchievementView @refresh, @current_user
      @new_achievement_view.router = this

    if @check_unity()
      @show_modal @new_achievement_view, ach

  sresults: ->
    unless @results_view?
      @results_view = new MegaballWeb.Views.ResultsView @current_user, @results, @refresh
      @results_view.router = this

    @do_process 'results', @results_view, true

  news: ->
    if @check_unity()
      @show_modal @news_view

  init_settings: ->
    @settings_view = new MegaballWeb.Views.SettingsView @current_user
    @settings_view.router = this

  init_mail: ->
    @mail_view = new MegaballWeb.Views.MailView @refresh
    @mail_view.router = this

  init_header: ->
    @header_view = new MegaballWeb.Views.HeaderView {
      current_user: @current_user,
      router: @router
    }
    @header_view.router = this

  init_news: ->
    console.log 'news'
    @news_view = new MegaballWeb.Views.NewsView
    @news_view.router = this

  settings: ->
    if @check_unity()
      @show_modal @settings_view

  mail: ->
    if @check_unity()
      @show_modal @mail_view

  check_unity: ->
    console.log("check unity call")
    unless @unityObject?
      @navigate('/init_unity', true)
      return false

    return true

  switch_blocks: (first_block, second_block) ->
    console.log 'switch_blocks'
    $(second_block).show()
    if first_block != @play_view.el
      $(first_block).hide()
    else
      window.u_minimize_unity()
    $(second_block).focus()

  do_process: (@route, view, only=false, tab)->
    #@modal_end()
    @main_tabs.activate @route

    @current_view?.navigated_from?()
    @current_view = view

    console.log(@route + " route")

    if only
      @main_tabs.$el.hide()
    else
      @main_tabs.$el.show()

    unless @check_unity()
      return

    if !@current_block or @current_block != view.el
      @switch_blocks(@current_block, view.el)
      @current_block = view.el

    view.navigated?(tab)

  show_modal: (view, data) ->
    cmodal = @current_modal
    cmodal?.$el.fadeOut('fast')
    @current_modal = view

    view.navigated_modal?(data)
    view.$el.fadeIn('fast')

    @modal_begin()

    view.hide_modal = (route) =>
      @modal_end()

      view.$el.fadeOut('fast')
      if route?
        @current_modal = null
        @navigate route, true
      else if cmodal? and cmodal != @current_modal
        @current_modal = cmodal
        @current_modal.$el.fadeIn('fast')
      else
        @current_modal = null
        @navigate @route, true

  modal_begin: ->
    @modal_counter += 1
    @play_view.$el.find('.unity-wrapper').css {
      position: 'fixed'
      top: '0px'
      left: '100%'
    } if @play_view?

  modal_end: ->
    @modal_counter -= 1 if @modal_counter > 0
    @play_view.$el.find('.unity-wrapper').css {
      position: 'relative'
      left: '0%'
    } if @play_view? and @modal_counter <= 0

