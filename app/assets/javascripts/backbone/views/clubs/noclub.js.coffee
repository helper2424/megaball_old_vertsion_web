class MegaballWeb.Views.NoClubView extends MegaballWeb.Views.MasterView

  css_class: 'noclub'

  events:
    'click .do-create:not(.inactive)':'create_club'
    'click .do-join:not(.inactive)':'join_club'

  initialize: ->
    super

    @include MegaballWeb.Views.Helpers.ClubPayer

    @item = window.megaball_config.club_price_list.create

  navigated: ->
    @current_user = @options.current_user
    @controller = @options.controller
    @render()

  render: ->
    if @item.user_level > @current_user.get_level()
      @$el.find('.do-create').addClass('inactive')
    else
      @$el.find('.do-create').removeClass('inactive')

    @$el.find('.price-list.star').hide() if @item.real < 0
    @$el.find('.price-list.coin').hide() if @item.imagine < 0

    @$el.find('.level-bound').text @item.user_level
    @$el.find('.price-list.star').text @item.real
    @$el.find('.price-list.coin').text @item.imagine

  create_club: -> @pay_for 'create', (currency) =>
    view = new MegaballWeb.Views.ClubCreateView currency: currency
    view.on 'created', @context @created
    view.show()

  created: ->
    @controller.navigated()

  join_club: ->
    @controller.navigate 'club_ratings'
