class Payment::OkController < ApplicationController
  include ApplicationHelper 
  include PaymentHelper

  def callback
    I18n.locale = :en
    #check signature
    sig = params[:sig].to_s
    params_string = ''

    if !request.query_parameters.nil? and !request.query_parameters.empty? 
      request.query_parameters.keys.sort.each do |key|
        if key != 'sig'
          params_string += key.to_s + '=' + params[key].to_s
        end
      end
    end

    response_error_code = nil
    response_xml = Builder::XmlMarkup.new
    response_xml.instruct!

    # check application settings
    if sig.nil? or sig.empty? or sig.length != 32 or
      sig != Digest::MD5.hexdigest(params_string + MEGABALL_IFRAME_CONFIG['ok']['secret_key'].to_s)
        response_xml.tag!("ns2:error_response", "xmlns:ns2" => 'http://api.forticom.com/1.0/') do
          response_xml.error_code 104
          response_xml.error_msg 'PARAM_SIGNATURE : '+t(:incorrect_signature)
        end

        response_error_code = 104 
    else
      payment_options = MEGABALL_CONFIG['payment']['ok']

      item_data = parse_item(params[:product_code])

      mongo_user = User.where('oauth_providers.provider' => 'odnoklassniki', 'oauth_providers.uid' => params[:uid].to_s).first
            
      acid_user = nil

      AcidPaymentTransaction.transaction do
        if mongo_user
          acid_user = AcidUser.find(mongo_user._id, lock: true)
        end

        if acid_user.nil?
          response_xml.tag!("ns2:error_response", "xmlns:ns2" => 'http://api.forticom.com/1.0/') do
            response_xml.error_code 1001
            response_xml.error_msg 'CALLBACK_INVALID_PAYMENT :'+t(:undefined_user)
          end

          response_error_code = 1001
        else
          if !item_data or item_data.empty?
            response_xml.tag!("ns2:error_response", "xmlns:ns2" => 'http://api.forticom.com/1.0/') do
              response_xml.error_code 1001
              response_xml.error_msg 'CALLBACK_INVALID_PAYMENT :'+t(:incorrect_product_code)
            end

            response_error_code = 1001
          else
            currencies= AcidCurrency.current 'ok'

            if currencies[:real].nil? or currencies[:imagine].nil?
              response_xml.tag!("ns2:error_response", "xmlns:ns2" => 'http://api.forticom.com/1.0/') do
                response_xml.error_code 1001
                response_xml.error_msg 'CALLBACK_INVALID_PAYMENT :'+t(:incorrect_product_code)
              end

              response_error_code = 1001
            else
              transaction_id = nil

              transaction_exists = AcidPaymentTransaction.where(additional: params[:transaction_id].to_s).first

              if transaction_exists
                transaction_id = transaction_exists.id
              else
                currency_type = item_data[:currency] == 'star' ? :real : :imagine

                if !check_exists_bonuses item_data, payment_options, currency_type
                  response_xml.tag!("ns2:error_response", "xmlns:ns2" => 'http://api.forticom.com/1.0/') do
                    response_xml.error_code 1001
                    response_xml.error_msg 'CALLBACK_INVALID_PAYMENT :'+t(:incorrect_product_code)
                  end

                  response_error_code = 1001
                else

                  current_currency = currencies[currency_type]
                  calculated_price = AcidCurrency.calculate_price item_data[:amount], current_currency

                  if calculated_price == params[:amount].to_i
                    transaction = AcidPaymentTransaction.new date: DateTime.now, gate_currency_amount: calculated_price, our_currency_amount: item_data[:amount], bonus: item_data[:bonus], additional: params[:transaction_id].to_s.gsub(/[^0-9]/, '')
                    transaction.acid_user = acid_user
                    transaction.acid_currency = current_currency
                    transaction.save!

                    if !acid_user.payment currency_type, item_data[:amount], item_data[:bonus]
                      raise ActiveRecord::Rollback, "User currency update problem"
                    end

                    StatsWorker.perform_for_user(mongo_user, :payment, {
                      item: currency_type,
                      social_network: 'odnoklassniki',
                      quantity: (item_data[:amount] + item_data[:bonus]),
                    })

                    transaction_id = transaction.id
                  else
                    response_xml.tag!("ns2:error_response", "xmlns:ns2" => 'http://api.forticom.com/1.0/') do
                      response_xml.error_code 1001
                      response_xml.error_msg 'CALLBACK_INVALID_PAYMENT :'+t(:incorrect_price)
                    end

                    response_error_code = 1001     
                  end  
                end 
              end                   
                
              if transaction_id
                response_xml.callbacks_payment_response(xmlns: "http://api.forticom.com/1.0/") { response_xml.text! "true" }
              else
                response_xml.tag!("ns2:error_response", "xmlns:ns2" => 'http://api.forticom.com/1.0/') do
                  response_xml.error_code 1
                  response_xml.error_msg 'UNKNOWN :'+t(:cant_save_transaction)
                end

                response_error_code = 1
              end
            end
          end
        end
      end
    end

    response_status = :ok
    unless response_error_code.nil?
      response.headers['invocation-error'] = response_error_code.to_s 
      response_status = :internal_server_error
    end

    render xml: response_xml.target!, status: response_status
  end
end
