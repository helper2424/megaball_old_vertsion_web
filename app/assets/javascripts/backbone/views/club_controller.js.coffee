class MegaballWeb.Views.ClubControllerView extends MegaballWeb.Views.MasterView
  el: "#club_block"

  events:
    'click .do-chat-show':'do_chat_show'

  initialize: (@club, @current_user, @router) ->

    # models
    @club.on 'sync', (m) =>
      MegaballWeb.Views.PopupView.loading_hide()
      @club.clear() unless m.present()
    @club.on 'fetch', => MegaballWeb.Views.PopupView.loading_show()

    # defined routes
    @routes = {
      home: {
        $el: undefined }

      default: new MegaballWeb.Views.ClubView {
        router: @router
        el: @$el.find('.tab-content.default')
        current_user: @current_user
        club: @club }

      noclub: new MegaballWeb.Views.NoClubView {
        el: @$el.find('.tab-content.noclub')
        controller: @
        current_user: @current_user }

      club_ratings: new MegaballWeb.Views.ClubRatingsView {
        el: @$el.find('.tab-content.rate')
        controller: @
        club: @club }
    }

    # create tabs
    @tabs = new MegaballWeb.Views.MainTabs el: @$el.find '.tabs'
    @tabs.on 'navigate', @context @navigate
  
  navigated: ->
    @club.fetch {
      success: (m) =>
        @routes.home = if m.present() then @routes.default else @routes.noclub
        @navigate 'home'
    }

  navigate: (tab) ->
    view = @routes[tab]
    return unless view?
    if @current_view?
      @current_view.$el.hide()
      @$el.removeClass @current_view.css_class
    view.$el.show()
    @current_view = view
    @$el.addClass @current_view.css_class
    @current_view.navigated?()
    @tabs.activate tab

  do_chat_show: ->
    @router.club_chat()
