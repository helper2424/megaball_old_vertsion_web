# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

class MegaballWeb.Payment.OK extends MegaballWeb.Payment.Default

  pay: (type='star', amount=10, bonus=0, portal_price=0, portal_amount_text='', amount_text='') ->
    item = "#{type}_#{amount}"
    item += "_#{bonus}" if bonus > 0
    console.log "Buying #{amount} of #{type} + #{bonus} (ok: #{item}), portal price #{portal_price}"
    FAPI.UI.showPayment "#{amount + bonus} #{amount_text}", window.t.payment_description_stars, item, portal_price, {},'[]','ok', 'true'

  special_offer: ->
    console.log "Special offer"
    new MegaballWeb.Views.PopupView.alert('В данной социальной сети недоступны акции')


