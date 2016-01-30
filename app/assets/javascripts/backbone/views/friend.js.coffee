class MegaballWeb.Views.FriendView extends MegaballWeb.Views.MasterView
  tagName:'div'
  template: _.template( $('#friend_template').html() )
  attributes:
    class:'friend'

  menu: '.menu'
  friend: '.bg, .glass, .cover, .online, .picture'

  events:
    'click .glass':'clicked'
    'click .do-get-energy:not(.inactive)':'do_get_energy'
    'click .do-get-energy.inactive':'cant_get_energy'
    'click .page-link':'go_to_user_page'
    'click .add-to-group:not(.inactive)':'add_to_group'
    'click .show-statistics:not(.inactive)':'show_statistics'
    'mouseenter .glass':'show_friend_control'
    'mouseleave':'hide_friend_control'

  initialize: ->
    super
    console.log("Initialization Friend view")
    @user = @options.user
    @online = @options.online ? 'OFFLINE'
    @render()

    if @user?
      @$el.find('.show-statistics').removeClass('inactive')

  render: ->
    @$el.html @template {
      level: @user?.get_level() ? false
      online: @online
    }
    @get_energy = @$el.find('.do-get-energy')
    @$el.find('.bg').css 'background', 'url(\'' + @model.get('image') + '\') center center no-repeat' if @model?
    if @user?
      @$el.find('.show-statistics').removeClass('inactive')
      @$el.find('.cover').remove()
      @user_picture = new MegaballWeb.Views.UserPictureView el: @$el.find('.picture')
      @user_picture.set_params platform: 'mini'
      @user_picture.from_user @user
      @get_energy[if @user.been_today() then 'addClass' else 'removeClass']('inactive')
    else
      @get_energy.addClass 'inactive'
    @

  clicked: -> unless @model
    MegaballWeb.main_router.navigate('/profile', true)
    window.social_service.show_invite_box()

  go_to_user_page: ->
    if @model
      console.log  window.social_service
      window.open window.social_service.user_page(@model.get('id')), '_blank'

  show_friend_control: ->
    return unless @model
    @$el.find(@friend).finish().animate {'margin-top': '200%'}, 'fast'
    @$el.find(@menu).finish().animate {'margin-top': '0'}, 'fast'

  hide_friend_control: ->
    return unless @model
    @$el.find(@friend).finish().animate {'margin-top': '0'}, 'fast'
    @$el.find(@menu).finish().animate {'margin-top': '-200%'}, 'fast'

  add_to_group: ->
    window.u_group_action 3, [@user.get('_id')]

  show_statistics: ->
    if @user?
      MegaballWeb.main_router.modal_begin()
      modal = new MegaballWeb.Views.StatisticsView user: @user
      modal.on 'any', => MegaballWeb.main_router.modal_end()
      modal.request_and_show @user

  do_get_energy: ->
    MegaballWeb.Views.PopupView.loading_show()
    energy = window.user_default.energy_per_friend
    link = @user.provider_info().link

    $.ajax {
      type: 'POST'
      url: '/energy_requests'
      data: {
        friend_id: @user.get('_id')
      }
      success: (o) =>
        window.social_service.energy_request_box @user
        if o.error?
          MegaballWeb.Views.PopupView.loading_hide()
          MegaballWeb.Views.PopupView.alert \
            "Вы уже отправили запрос этому игроку!"
        else
          MegaballWeb.Views.PopupView.loading_hide()
          MegaballWeb.Views.PopupView.alert \
            """<span class='compact'>
                 Когда этот игрок зайдет, 
                 Вам зачислится #{energy} пунктов энергии! <br/>
                 <a href='#{link}' target='_blank'>перейти на страницу в соц. сети</a>
               </span>
            """
    }


  cant_get_energy: ->
    MegaballWeb.Views.PopupView.alert if @model?
      "Этот игрок сегодня заходил в игру. Вы можете позвать его завтра."
    else
      "Приглашайте друзей, чтобы получать больше энергии каждый день!"
