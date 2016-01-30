MegaballWeb.Payment = {}

class MegaballWeb.Payment.Default

  pay: (type='star', amount=10, bonus=0, portal_price=0, portal_amount_text='', amount_text='') ->
    console.log "Buying #{amount} of #{type} + #{bonus}"
    new MegaballWeb.Views.PopupView.alert('Внесение средств пока не доступно')

  special_offer: ->
    console.log "Special offer"
    new MegaballWeb.Views.PopupView.alert('Внесение средств пока не доступно')
