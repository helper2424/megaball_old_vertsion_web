class MegaballWeb.Views.MainView extends MegaballWeb.Views.MasterView
  el: "#fast_matches_block"

  initialize: (@current_user, @game_plays, @router) ->

    # defined routes
    @routes = {
      matches: new MegaballWeb.Views.FastMatchesView {
        el: @$el.find('.tab-content.matches')
        router: @router
        current_user: @current_user
        game_plays: @game_plays
      }
    }

    # create tabs
    @tabs = new MegaballWeb.Views.MainTabs el: @$el.find '.tabs'
    @tabs.on 'navigate', @context @navigate
  
  navigated: ->
    @navigate 'matches'

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
