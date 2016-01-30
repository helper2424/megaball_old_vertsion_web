class MegaballWeb.Views.NameEditorView extends MegaballWeb.Views.MasterView
  tagName: 'div'
  template: _.template $('#name_editor_template').html()

  events:
    'click .name .text':'edit_name'
    'click .editor .edit':'edit_name'
    'click .editor .accept':'accept_name'
    'click .editor .cancel':'cancel_name'
    'keypress .text-editor':'keypressed'

  match:
    'accept'   :'.editor .accept'
    'cancel'   :'.editor .cancel'
    'edit'     :'.editor .edit'
    'text'     :'.name .text'
    'text_e'   :'.name .text-editor'
    'enabled'  :'.name .text-editor, .editor .on-enabled'
    'disabled' :'.name .text, .editor .on-disabled'


  initialize: ->
    super
    @editing = false

  set_user: (@current_user) ->
    @current_user.on 'all', @context @render
    @render()

  render: ->
    unless @editing
      @$el.html @template()
      @$('text').html(@current_user.get 'name')
      @cancel_name()

  $: (t) -> @$el.find @match[t]

  edit_name: ->
    @editing = true
    @$('text_e').val @$('text').html()
    @$('enabled').show()
    @$('disabled').hide()
    @$('text_e').focus()

  accept_name: ->
    @editing = false
    @current_user.save {'name': $.trim @$('text_e').val()},
      success: @context (model, response, options)->
        @current_user.set 'name', response.name
      patch: true
      wait: true
      error: (u,xhr) =>
        if xhr.responseJSON.name? then MegaballWeb.Views.PopupView.alert 'Имя уже занято'
        else MegaballWeb.Views.PopupView.alert 'Неизвестная ошибка'

  cancel_name: ->
    @editing = false
    @$('enabled').hide()
    @$('disabled').show()

  keypressed: (e) ->
    @accept_name() if e.which == 13
