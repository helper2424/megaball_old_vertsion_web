class MegaballWeb.Views.NewsView extends MegaballWeb.Views.MasterView
  el: "#news_block"


  events:
    'click .ok-green':'hide'

  initialize: (@current_user) ->
    super
    console.log 'Initialization news view'
#    $("#news-picture").attr('src', '123')

  hide: ->
    @hide_modal()