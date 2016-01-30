$ ->

  log = $ "#server_log"
  auto_scroll = $ "#auto_scroll"
  timeout = 1000
  last_count = -1

  render_lines = (lines) ->
    for line, i in lines
      el = $('<div class="line"></div>').html(line)
      el.addClass 'exception' if /exception/i.test(line)
      el.addClass 'warn' if /warn/i.test(line)
      log.append el
    $('body').scrollTop log.height() if auto_scroll.is ':checked'

  update_from_server = (count = undefined) ->
    params = { 'from': last_count }
    params['lines'] = count if count?
    $.getJSON window.log_path, params, (data) ->
      if last_count != data.count
        render_lines data.lines
        last_count = data.count
      setTimeout update_from_server, timeout

  update_from_server window.lines_count
