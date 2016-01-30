class MegaballWeb.Views.ClubChat extends MegaballWeb.Views.MasterView
  el: '#club_chat'

  chat_message_tpl: """
    <div class='chat-message'>
      <div class='sender'></div>
      <div class='body'></div>
    </div>
  """

  events:
    'keypress .club-chat-input':'keypressed'
    'click .club-chat-send':'send'
    'click .do-close':'do_close'

  initialize: ->
    @club = @options.club
    @current_user = @options.current_user
    
    @input = @$el.find('.club-chat-input')
    @chat_log = new MegaballWeb.Views.ScrollView el: @$el.find('.chat-log')

    window.u_events.on 'chat_receive_message', @on_message, @
    window.u_events.on 'chat_receive_system_message', @on_sys_message, @

  navigated_modal: ->
    window.u_chat_connect()

  keypressed: (e) -> @send() if e.which == 13

  send: ->
    window.u_chat_send_message @input.val()
    @input.val ''

  do_close: ->
    @hide_modal()

  on_sys_message: (message) ->
    @on_message { default_name: 'администрация', body: message }, 'system'

  on_message: ({sender, body, default_name}, add_class) ->
    user = _.findWhere(@club.get('users'), {_id: sender})
    message = $ @chat_message_tpl
    message.find('.sender').text(user?.name ? default_name ? 'unknown')
    message.find('.body').text body
    message.addClass('me') if user?._id == @current_user.get('_id')
    message.addClass(add_class) if add_class?
    @chat_log.$().append message if body.length > 0
    @chat_log.scroll_down()
