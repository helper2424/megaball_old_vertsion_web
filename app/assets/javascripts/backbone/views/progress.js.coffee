class MegaballWeb.Views.ProgressView extends MegaballWeb.Views.MasterView
  el: "#progress_block"
  current_tab: 'achievements'

  events:
    'click .store-right':'next_page'
    'click .store-left':'prev_page'

  initialize: (@current_user, @refresh) ->
    super
    console.log("Initialization progress view")

    @layout = @$el.find('.progress')
    @tabs = new MegaballWeb.Views.MainTabs el: @$el.find('.tabs')
    @tabs.on 'navigate', (it) => @navigate {tab: it}

    @views = {
      achievements: new MegaballWeb.Views.AchievementsView {
        el: @layout.find('.content.achievements')
        user: @current_user
      }
      user_stat: new MegaballWeb.Views.UserStatView {
        el: @layout.find('.content.user_stat')
        user: @current_user
      }
      collections: new MegaballWeb.Views.CollectionsView {
        el: @layout.find('.collections')
        user: @current_user
        refresh: @refresh
      }
    }

  navigated: ->
    @navigate tab: @current_tab

  navigate: ({tab, id}) ->
    return unless tab?
    view = @views[tab] ? @views[_.keys(@views)[0]]
    @layout.removeClass @current_tab
    @layout.find(".content.#{@current_tab}").hide()
    @current_tab = tab
    @layout.addClass @current_tab
    @layout.find(".content.#{@current_tab}").show()
    view.navigated(id)
    @tabs.activate tab
