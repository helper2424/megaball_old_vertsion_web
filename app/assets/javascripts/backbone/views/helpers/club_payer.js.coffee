#= require ../currency_picker

class MegaballWeb.Views.Helpers.ClubPayer

  __get_action: (action) ->
    if action == 'upgrade'
      @club?.level_info().upgrade
    else
      window.megaball_config.club_price_list[action]

  action_level: (action) ->
    item = @__get_action action
    return false unless item?

    if @club? and item.level? and @club.get('level') < item.level
      MegaballWeb.Views.PopupView.alert "Уровень клуба должен быть не меньше #{item.level}"
      false
    else
      true

  pay_for: (action, callback) ->
    item = @__get_action action
    return unless item?

    return unless @action_level action
    return if item.real < 0 and item.imagine < 0
    return callback 'stars', 0 if item.real == 0
    return callback 'coins', 0 if item.imagine == 0

    picker = new MegaballWeb.Views.CurrencyPickerView {
      stars: item.real
      coins: item.imagine
    }
    picker.on 'pick', (c, a) =>
      if @club? and @club.get(c) < a
        @trigger 'not_enough_money', c, a, => callback? c, a
      else
        callback? c, a
    picker.show()
