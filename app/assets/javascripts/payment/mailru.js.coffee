class MegaballWeb.Payment.MailRu extends MegaballWeb.Payment.Default

  pay: (type='star', amount=10, bonus=0, portal_price=0, portal_amount_text='', amount_text='') ->
    item = "#{type}_#{amount}"
    item += "_#{bonus}" if bonus > 0
    console.log "Buying #{amount} of #{type} + #{bonus} (vk: #{item})"
    mailru.app.payments.showDialog 
      service_id: item
      service_name: "#{amount + bonus} #{amount_text}"
      mailiki_price: portal_price

  special_offer: ->
    console.log "Special offer"
    new MegaballWeb.Views.PopupView.alert('В данной социальной сети недоступны акции')