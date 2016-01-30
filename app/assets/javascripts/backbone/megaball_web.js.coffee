#= require_self
#= require_tree ./templates
#= require ./views/master
#= require_tree ./views
#= require_tree ./models
#= require_tree ./routers

_.templateSettings =
  interpolate: /\{\{\=(.+?)\}\}/g
  evaluate: /\{\{(.+?)\}\}/g

String::format_date = ->
  date = new Date(this)
  if (date.getFullYear() < 2000)
    "нет данных"
  else
    date.getDate() + "/" + (date.getMonth() + 1) + "/" + date.getFullYear()

Number::format_with_k = ->
  res = "#{this}"
  count = Math.ceil(res.length / 3) - 1
  res[0..res.length - count*3 - 1] + ('k' for x in [0...count]).join('')


Number::format_date_from_millis = ->
  num = this / 1000 # secs
  return "#{Math.round(num)} сек." if Math.round(num / 60) <= 0
  return "#{Math.round(num / 60)} мин." if Math.round(num / (60 * 60)) <= 0
  return "#{Math.round(num / (60 * 60))} ч." if Math.round(num / (60 * 60 * 60)) <= 0
  "#{Math.round(num / (60 * 60 * 24))} дн."

window.MegaballWeb =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {
    Helpers: {}}
  Social: {}
  Init: ->

    context = MegaballWeb

    context.current_user = new MegaballWeb.Models.User window.current_user_data

    context.game_plays = new MegaballWeb.Collections.GamePlaysCollection

    context.main_router = new MegaballWeb.Routers.MainsRouter context.current_user, context.game_plays
        
    window.payment_source = new MegaballWeb.Payment.Default unless window.payment_source?

    window.social_service = new MegaballWeb.Social.Default unless window.social_service?

    context.currencies = new MegaballWeb.Views.CurrenciesView user: context.current_user, router: context.main_router
  
    $(document).mousemove (e) ->
      window.mouse_position = {
        x: e.clientX
        y: e.clientY
        scroll_x: e.pageX
        scroll_y: e.pageY
      }

    if window.invite
      context.invite = new MegaballWeb.Views.Invite

    window.sub_zero_price_stub = '---'
    
    $('.navigation-help').show()

    $('.help_me').find('button').click ->
       window.social_service.help_me()

    if Backbone.history
      Backbone.history.start()

  VKInit: ->
    console.log "Vk inited"

    that = @
    VK.api('friends.getAppUsers', {}, (data) ->

      friend_ids = data.response
      if !data.response or !data.response.length
        friend_ids = []

      that.friends_view = new MegaballWeb.Views.FriendsView friend_ids, MegaballWeb.current_user
    )

    window.payment_source = new MegaballWeb.Payment.Vkontakte
    window.social_service = new MegaballWeb.Social.Vkontakte

    VK.addCallback 'onOrderSuccess', _.bind (order_id)->
        window.payment_source.orderSuccess?()
        @currencies.bank.hide()
        @current_user.fetch()
        console.log 'Success payment'
      , @
    
    VK.addCallback 'onOrderFail', _.bind ->
        window.payment_source.orderFail?()
        new MegaballWeb.Views.PopupView.alert('При покупке валюты произошла ошибка, повторите операцию позже, и напишите о проблеме в группе приложения')
        #Raven.captureMessage('Vk payment problem, user:'+@current_user.toJSON(), {tags: { key: "payment" }})
      , @

    VK.addCallback 'onOrderCancel', =>
      window.payment_source.orderCancel?()
      console.log 'Cancel order'

    VK.addCallback 'onWindowBlur', =>
      MegaballWeb.main_router.modal_begin()
      console.log 'onWindowBlur'

    VK.addCallback 'onWindowFocus', =>
      MegaballWeb.main_router.modal_end()
      console.log 'onWindowFocus'

    window.special_offer = true

  MailRuInit: -> 
    console.log "Mailru inited"

    that = @

    window.social_service = new MegaballWeb.Social.MailRu
    console.log window.social_service
    window.payment_source = new MegaballWeb.Payment.MailRu

    mailru.events.listen mailru.app.events.incomingPayment, _.bind (event)->
        if event.status == 'success'
          @currencies.bank.hide()
          @current_user.fetch()
          console.log 'Success payment'
        else
          new MegaballWeb.Views.PopupView.alert('При покупке валюты произошла ошибка, повторите операцию позже, и напишите о проблеме в группе приложения')
      ,@

    mailru.common.friends.getAppUsers( (data) ->

      friend_ids = data

      if !data or !data.length
        friend_ids = []

      that.friends_view = new MegaballWeb.Views.FriendsView friend_ids, MegaballWeb.current_user
    )

  OkInit: -> 
    console.log "Ok inited"
    that = @

    #FAPI.UI.setWindowSize window.megaball_config.window_wrapper_width, window.megaball_config.window_wrapper_height

    window.API_callback = (method, result, data)->
      if method == 'showPayment'
        if result == 'ok'
          @currencies.bank.hide()
          @current_user.fetch()
          console.log 'Success payment'
        else
          new MegaballWeb.Views.PopupView.alert('При покупке валюты произошла ошибка, повторите операцию позже, и напишите о проблеме в группе приложения')
      else if method == 'showConfirmation'
        if window.ok_stream_publish_object?
          FAPI.Client.call {'method':'stream.publish', 'message':ok_stream_publish_object.message, 'attachment':{'src':ok_stream_publish_object.image, 'type':'image', 'resig':data}}, (status, data, error) ->
            console.log status
            console.log data
            console.log ok_stream_publish_object.image,
      else
        true

    window.API_callback = _.bind window.API_callback, @

    FAPI.UI.setWindowSize 800, 900
    FAPI.Client.call {"method":"friends.getAppUsers"}, (status, data, error) ->
      if status == "ok"

        friend_ids = []

        if data and data.uids and data.uids.length
          friend_ids = data.uids

        that.friends_view = new MegaballWeb.Views.FriendsView friend_ids, MegaballWeb.current_user
      else
        console.log "ERROR : " +error.error_msg+"("+error.error_code+")"

$ window.MegaballWeb.Init
