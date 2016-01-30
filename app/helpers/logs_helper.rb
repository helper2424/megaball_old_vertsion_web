module LogsHelper
  def link_with_highlight(title, action)
    url = url_for controller: 'logs', action: action
    link_to title, url, class: current_page?(url) ? 'selected' : ''
  end

  def get_positive_int_param(param, default)
    res = request.GET.has_key?(param) ? request.GET[param].to_s.to_i : default
    (res < 0) ? default : res
  end
end
