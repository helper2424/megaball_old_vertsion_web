class MegaballWeb.Views.ClubPictureView extends MegaballWeb.Views.MasterView
  nologo: '<button class="button noclublogo"></button>'

  loader: """
    <div class='picture'>
      <div class='loader'>
        <div class='progress'></div>
      </div>
      <div class='glass club-logo-glass'></div>
    </div>
  """

  logo_tempalte: _.template """
    <div class='picture'>
      <img src='{{=src}}' />
      <div class='glass club-logo-glass'></div>
    </div>
  """

  initialize: ->
    @include MegaballWeb.Views.Helpers.ClubRoleManager

    @club = @options.club
    @inactivate = @options.inactivate ? false

    @form = $ """
      <form method='post' 
            enctype='multipart/form-data' 
            action='/club/update_logo'>
        <input type='file' name='logo' />
        <input type='hidden' name='currency' />
      </form>
    """
    @file_source = @form.find 'input[name=logo]'
    @currency = @form.find 'input[name=currency]'
    @file_source.change @context @file_selected

  render: ->
    @$el.html(
      if @logo?
        @logo_tempalte src: window.assetRootPath + @logo
      else
        @nologo)

    @$el.find('.button').addClass('inactive') if @inactivate
        
  file_dialog: (currency) ->
    @currency.val currency
    @file_source.trigger('click')

  file_selected: ->
    return if @file_source[0].files.length <= 0
    MegaballWeb.Views.PopupView.loading_show()
    reader = new FileReader
    reader.onerror = (e) => MegaballWeb.Views.PopupView.loading_hide()
    reader.onload = (e) => @form.ajaxSubmit {
      success: @context @file_uploaded
      error: @context @file_error }
    reader.readAsDataURL @file_source[0].files[0]

  file_uploaded: (text, status, xhr) ->
    MegaballWeb.Views.PopupView.loading_hide()
    if text.error?
      @trigger 'update_error', text.error
    else
      @trigger 'updated'

  file_error: ->
    MegaballWeb.Views.PopupView.loading_hide()
    @trigger 'update_error', 'server_error'

  set_logo: (logo) ->
    @logo = logo
    @render()

