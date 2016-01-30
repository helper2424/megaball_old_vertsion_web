#= require_tree ./helpers
#= require_tree ./clubs

class MegaballWeb.Views.ClubView extends MegaballWeb.Views.MasterView

  css_class: 'home'

  events:
    'click .name:not(.inactive)':'name_edit'
    'click .short-name:not(.inactive)':'name_edit'
    'click .name-edit-trig':'name_edit'
    'click .name-accept-trig':'name_accept'
    'click .name-decline-trig':'name_decline'
    'click .status:not(.inactive)':'status_edit'
    'click .status-edit-trig':'status_edit'
    'click .status-accept-trig':'status_accept'
    'click .status-decline-trig':'status_decline'
    'click .leave-club':'leave_club'
    'click .logo:not(.inactive)':'update_logo'
    'click .do-transfer':'manual_transfer'
    'click .do-upgrade':'do_upgrade'
    'click .requests-show:not(.inactive)':'requests_show'

  restrictions: {
    0: {
      inactivate: '.requests-show, .name, .short-name, .status, .logo'
      hide: '.name-edit-trig, .status-edit-trig, .user-kick, .do-upgrade'} }

  initialize: (@current_user) ->
    super
    console.log("Initialization Club view")

    @include MegaballWeb.Views.Helpers.ClubRoleManager
    @include MegaballWeb.Views.Helpers.ClubPayer

    # arguments
    @router = @options.router
    @club = @options.club
    @current_user = @options.current_user

    # fields
    @name = @$el.find '.name'
    @short_name = @$el.find '.short-name'
    @status = @$el.find '.status'
    @place = @$el.find '.place'
    @rating = @$el.find '.rating'
    @level = @$el.find '.level'
    @stars = @$el.find '.stars-label'
    @coins = @$el.find '.coins-label'
    @members = @$el.find '.members'
    @upgrader = @$el.find '.do-upgrade'
    @logo = new MegaballWeb.Views.ClubPictureView el: @$el.find '.logo'
    @users = new MegaballWeb.Views.ScrollView el: @$el.find '.users'
    @users_list = @users.$().find('ul')
    @tabs = new MegaballWeb.Views.MainTabs el: @$el.find '.tabs'
    @requestsbtn = @$el.find('.requests-show span')

    # views
    @transfer = new MegaballWeb.Views.ClubTransferView

    # editors
    @name_editor = new MegaballWeb.Views.ClubEditor {
      min_length: 4
      normal: @$el.find '.name'
      edit: @$el.find '.name-edit'
      normal_controls: @$el.find '.name-edit-trig'
      edit_controls: @$el.find '.name-accept-trig, .name-decline-trig'}
    @short_name_editor = new MegaballWeb.Views.ClubEditor {
      min_length: 2
      normal: @$el.find '.short-name'
      edit: @$el.find '.short-name-edit'} # controls are same as for name_editor
    @status_editor = new MegaballWeb.Views.ClubEditor {
      normal: @$el.find '.status'
      edit: @$el.find '.status-edit'
      normal_controls: @$el.find '.status-edit-trig'
      edit_controls: @$el.find '.status-accept-trig, .status-decline-trig'}

    # event bindings
    @on 'not_enough_money', @context @not_enough_money # triggered in payer
    @club.on 'sync', @context @update_club_user
    @name_editor.on 'accept', @context @name_accepted
    @status_editor.on 'accept', @context @change_status
    @logo.on 'updated', => @club.fetch()
    @logo.on 'update_error', (e) => @[e]?()
    @transfer.on 'act', @context @do_transfer

  update_club_user: ->
    @club_user = _.where(
      @club.get('users'),
      { _id: @current_user.get('_id') })[0]
    @render()

  render: ->
    console.log("Render Club view")

    # fields
    @name.text       @club.get 'name'
    @short_name.text @club.get 'short_name'
    @status.text     @club.get 'status_message'
    @rating.text     @club.get('rating')?.format_with_k()
    @place.text      @club.get 'place'
    @stars.text      @club.get 'stars'
    @coins.text      @club.get 'coins'
    @level.text      @club.get 'level'
    @logo.set_logo   @club.get 'logo'
    @members.text    "#{@club.get 'members_count'} / #{@club.level_info().max_players}"

    @upgrader[if @club.get('level') >= \
      window.megaball_config.club_defaults.max_level then \
      'hide' else 'show']()

    # club users
    @render_club_users()

    # roles restrictions
    @apply_restrictions @club_user.role if @club_user?

    if @club_user? and @club_user.role > 0
      @requestsbtn.text if @club.get('request_count') == 0 then ''
      else ": #{@club.get 'request_count'}"
    else
      @requestsbtn.text ''

  render_club_users: ->
    @users_list.html ''
    @user_club_views =
      _.map(
        _.sortBy(
          @club.get('users'),
          (x) -> x.place_in_club),
        (it, i) => new MegaballWeb.Views.ClubUserView {
          club_user: @club_user
          model: it
          index: i + 1
          hide_kick: it._id == @current_user.get('_id') || it.role >= @club_user.role
          accent: it._id == @current_user.get('_id')
        })

    for view in @user_club_views
      @users_list.append view.$el
      view.on 'kick', @context @kick
      view.on 'setrole', @context @setrole

  do_job: (action, args) ->
    error = args.error ? ((e) => @[e]?())
    $.ajax
      url: "/#{args.method ? 'club'}/#{action}" + (if args.url? then "/#{args.url}" else "")
      type: 'POST'
      data: args.data
      error: (xhr) => error 'server_error'
      success: (obj) => if obj.error? then error(obj.error) else
        args.callback?(obj)

  # event handlers
  
  name_accept: ->
    console.log('check club name')
    if not @name_editor.accept()
      MegaballWeb.Views.PopupView.alert 'Имя клуба должно быть от 4 до 20 символов длиной!'
      @name_editor.start_edit(@name_editor.value)
  name_edit: ->
    @name_editor.start_edit()
    @short_name_editor.start_edit()
  name_decline: ->
    @name_editor.decline()
    @short_name_editor.decline()
  status_edit: -> @status_editor.start_edit()
  status_accept: -> @status_editor.accept()
  status_decline: -> @status_editor.decline()
  name_accepted: ->
    console.log('check club short name')
    if not @short_name_editor.accept()
      MegaballWeb.Views.PopupView.alert 'Короткое имя должно быть от 2 до 4 символов длиной!'
      @name_editor.start_edit(@name_editor.value)
      @short_name_editor.start_edit(@short_name_editor.value)
      return
    @change_name()

  change_name: -> @pay_for 'rename', (currency, amount) =>
    @do_job 'rename', {
      data: {
        currency: currency
        name: @name_editor.value
        short_name: @short_name_editor.value
      }
      error: (error) =>
        if error == "same_name" then MegaballWeb.Views.PopupView.alert 'Имя не было изменено'
        else if error.name? then MegaballWeb.Views.PopupView.alert 'Клуб с таким именем уже существует'
        else if error.short_name? then MegaballWeb.Views.PopupView.alert 'Короткое имя занято другим клубом'
        else MegaballWeb.Views.PopupView.alert 'Неизвестная ошибка'
      callback: => @club.fetch()
    }

  change_status: ->
    @club.save {
      status_message: @status_editor.value
    }, {
      patch: true
    }

  leave_club: ->
    MegaballWeb.Views.PopupView.confirm {
      text: (if @club_user.role >= 2 then \
        'Вы действительно хотите распустить клуб? Все изменения будут потеряны!' else \
        'Вы действительно хотите выйти из клуба?')
      ok: @context @process_leave}

  process_leave: ->
    @do_job 'leave', {
      callback: => @router.navigate('/main', true) }

  update_logo: ->
    if @club.get('logo')?
      @pay_for 'update_logo', (currency) =>
        @logo.file_dialog(currency)
    else if @action_level 'update_logo'
      @logo.file_dialog 'stars'

  manual_transfer: ->
    @transfer.show()

  do_transfer: (args) ->
    @_shown_nem = false
    keys = _.keys args

    transferjob = =>
      currency = keys.pop()
      unless currency?
        @transfer.hide 'fast', =>
          @current_user.fetch()
          @club.fetch()
        return
      amount = args[currency]

      @do_job 'to_club', {
        method: 'transfer'
        data: {
          currency: currency
          amount: amount
        }
        error: =>
          MegaballWeb.Views.NotEnoughMoney.show() unless @_shown_nem
          @_shown_nem = true
          transferjob()
        callback: => transferjob()
      }
    transferjob()

  do_upgrade: -> if @club.get('level') >= window.megaball_config.club_defaults.max_level
      @reached_max_level()
    else
      @pay_for 'upgrade', (currency) =>
        @do_job 'upgrade', {
          data: {currency: currency}
          callback: => @club.fetch()
        }
 
  kick: (user) ->
    @do_job 'kick', {
      url: user._id
      callback: => @club.fetch()
    }

  setrole: (user, role, self) -> @pay_for 'role', (currency) =>
    @do_job 'role', {
      url: user._id
      data: {
        currency: currency
        role: role
      }
      callback: =>
        self.hide('fast', =>
          @club.fetch())
    }

  requests_show: ->
    @requests = new MegaballWeb.Views.ClubRequestListView
    @requests.on 'accept_user', @context @accept_user
    @requests.on 'reject_user', @context @reject_user
    @requests.show()
    @requests.request()

  accept_user: (m) -> @do_job 'accept', {
    url: m._id
    callback: => @requests.hide 'fast', =>
      @club.fetch()
  }

  reject_user: (m) -> @do_job 'reject', {
    url: m._id
    callback: => @requests.hide 'fast', =>
      @club.fetch()
  }
    
  # server responses

  not_enough_money: (currency, amount, callback) ->
    data = {}
    data[currency] = amount - @club.get(currency)
    @transfer.show data
    @club.fetch()

  level_is_low: ->
    MegaballWeb.Views.PopupView.alert 'Уровень клуба еще не достаточно большой!'
    @club.fetch()

  reached_max_level: ->
    MegaballWeb.Views.PopupView.alert 'Достигнут максимальный уровень!'
    @club.fetch()

  server_error: ->
    MegaballWeb.Views.PopupView.alert 'Проверьте правильность информации!'
    @club.fetch()
