module PaymentHelper
  def parse_item item
    false if item.nil? or item.empty?

    result = {}
    pattern = /^(?<currency>(coin|star|offer))\_(?<amount>\d{1,10})(\_(?<bonus>\d{1,10})){0,1}$/
    parse_result = item.to_s.match(pattern)

    if parse_result
      result[:currency] = parse_result['currency'].to_s
      result[:amount] = parse_result['amount'].to_s.to_i
      result[:bonus] = 0

      if parse_result['bonus']
        result[:bonus] = parse_result['bonus'].to_s.to_i
      end
    end

    result
  end

  def check_exists_bonuses item_data, payment_options, currency_type
    if item_data[:bonus].to_i == 0
      return item_data[:amount].to_i >= payment_options['min_payment'][currency_type].to_i
    end

    check_exists_payment_option = false
    payment_options[currency_type.to_s].each do |option|
      if option == [item_data[:amount].to_i, item_data[:bonus].to_i]
        check_exists_payment_option = true
        break
      end
    end

    return check_exists_payment_option
  end
end
