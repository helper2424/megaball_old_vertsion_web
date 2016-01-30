class MegaballWeb.Payment.Vkontakte extends MegaballWeb.Payment.Default

  constructor: ->
    super
    _.extend this, Backbone.Events

  pay: (type='star', amount=10, bonus=0, portal_price=0, portal_amount_text='', amount_text='') ->
    item = "#{type}_#{amount}"
    item += "_#{bonus}" if bonus > 0
    console.log "Buying #{amount} of #{type} + #{bonus} (vk: #{item})"
    VK.callMethod 'showOrderBox',
      type: 'item'
      item: item

  special_offer: (cb) ->
    console.log "VK special offer"
    VK.callMethod 'showOrderBox',
      type: 'offers'
      currency: true

  orderFail: ->
    @trigger 'all'
    @trigger 'orderFail'

  orderCancel: ->
    @trigger 'all'
    @trigger 'orderCancel'

  orderSuccess: ->
    @trigger 'all'
    @trigger 'orderSuccess'
