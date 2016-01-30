  # encoding: UTF-8

class Payment::MailruController < ApplicationController 
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

    response_json = {}

    # check application settings
    if sig.nil? or sig.empty? or sig.length != 32 or 
      params[:app_id].to_s != MEGABALL_IFRAME_CONFIG['mailru']['id'].to_s or
      sig != Digest::MD5.hexdigest(params_string + MEGABALL_IFRAME_CONFIG['mailru']['secret_key'].to_s)
        response_json = {
          error_code: '700',
          status: '2'
        }
    else
      payment_options = MEGABALL_CONFIG['payment']['mailru']

      item_data = parse_item(params[:service_id])

      mongo_user = User.where('oauth_providers.provider' => 'mailru', 'oauth_providers.uid' => params[:uid].to_s).first

      acid_user = nil

      AcidPaymentTransaction.transaction do
        if mongo_user
          acid_user = AcidUser.find(mongo_user._id, lock: true)
        end

        if acid_user.nil?
          response_json = {
            error_code: '701', 
            status: '2'
          }
        else
          if !item_data or item_data.empty?
            response_json = {
              error_code: '703', 
              status: '2' 
            }
          else
            currencies = AcidCurrency.current 'mailru'

            if currencies[:real].nil? or currencies[:imagine].nil?
              response_json = {
                error_code: '702', 
                status: '2' 
              }
            else

              if false #Rails.env.release? and params[:debug].to_s != '0'
                response_json = {
                  status: '1'
                }
              else
                transaction_id = nil

                transaction_exists = AcidPaymentTransaction.where(additional: params[:transaction_id].to_s).first

                if transaction_exists
                  transaction_id = transaction_exists.id
                else
                  currency_type = item_data[:currency] == 'star' ? :real : :imagine

                  if !check_exists_bonuses item_data, payment_options, currency_type
                    response_json = {
                      error_code: '703',
                      status: '2'
                    }
                  else

                    current_currency = currencies[currency_type]
                    calculated_price = AcidCurrency.calculate_price item_data[:amount], current_currency

                    if calculated_price == params[:mailiki_price].to_i
                      transaction = AcidPaymentTransaction.new date: DateTime.now, gate_currency_amount: calculated_price, our_currency_amount: item_data[:amount], bonus: item_data[:bonus], additional: params[:transaction_id].to_s.gsub(/[^0-9]/, '')
                      transaction.acid_user = acid_user
                      transaction.acid_currency = current_currency
                      transaction.save!

                      if !acid_user.payment currency_type, item_data[:amount], item_data[:bonus]
                        raise ActiveRecord::Rollback, "User currency update problem"
                      end

                      StatsWorker.perform_for_user(mongo_user, :payment, {
                        item: currency_type,
                        social_network: 'mailru',
                        quantity: (item_data[:amount] + item_data[:bonus]),
                      })

                      transaction_id = transaction.id
                    else
                      response_json = {
                        error_code: '703',
                        status: '2'      
                      }       
                    end  
                  end                    
                end

                if transaction_id
                  response_json = {
                    status: '1'
                  }
                else
                  response_json = {
                    error_code: '700',
                    status: '0'           
                  }
                end
              end
            end
          end
        end
      end
    end

    render json: response_json
  end
end
