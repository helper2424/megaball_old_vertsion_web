window.u_receive_web_servers = ->
  data = """
  {
    url: "#{window.rootPath}",
    assetUrl: "#{window.assetRootPath}"
  }
  """

  window.unityObject.getUnity().SendMessage("StateObject", "SetWebServers", data)

window.u_visible = (is_visible) ->
  unityWrapper = $ "#unityWrapper"
  if is_visible then unityWrapper.removeClass 'hidden'
  else unityWrapper.addClass 'hidden'

window.u_file_dialog = (currency = "stars") ->
  form = $ "#clubLogoUploader form"
  $fileSelector = form.find("input[type=file]")
  $currency = form.find("input[type=hidden]")
  $label = form.find("label")
  $currency.val currency

  unless form[0].initialized
    form[0].initialized = true

    $label.click -> $fileSelector.click()
    $filename = $("#clubLogoUploader .filename")
    $uploading = $("#clubLogoUploader .uploading")
    $doSelect = $("#clubLogoUploader .do-select")
    $doCancel = $("#clubLogoUploader .do-cancel")
    
    title = $filename.html()

    progressState = (filename) ->
      $uploading.show()
      $doSelect.hide()
      $doCancel.hide()
      $filename.text "\"#{filename}\""

    idleState = ->
      $uploading.hide()
      $doSelect.show()
      $doCancel.show()
      $filename.html title

    $fileSelector.change ->
      if $fileSelector[0].files.length < 1
        idleState()
      else
        file = $fileSelector[0].files[0]
        progressState file.name
        form.ajaxSubmit {
          success: (x) ->
            idleState()
            window.u_file_success(JSON.stringify(x))
          error: (x) ->
            idleState()
            window.u_file_error()
        }

    $doSelect.click -> $fileSelector[0].click()
    $doCancel.click -> window.u_file_cancel()

  window.u_visible(false)
  $("#clubLogoUploader").removeClass('hidden')

window.u_file_cancel = ->
  window.u_visible(true)
  $("#clubLogoUploader").addClass('hidden')
  window.unityObject.getUnity().SendMessage("ClubJsMediator", "CancelLogoUpload", "")

window.u_file_error = (error="unknown") ->
  window.u_visible(true)
  $("#clubLogoUploader").addClass('hidden')
  window.unityObject.getUnity().SendMessage("ClubJsMediator", "ErrorLogoUpload", error)

window.u_file_success = ->
  window.u_visible(true)
  $("#clubLogoUploader").addClass('hidden')
  window.unityObject.getUnity().SendMessage("ClubJsMediator", "SuccessLogoUpload", "")

