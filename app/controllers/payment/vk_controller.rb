  # encoding: UTF-8

class Payment::VkController < ApplicationController 
  include ApplicationHelper 
  include PaymentHelper
  include LocaleHelper

  before_filter :set_locale

  def callback

    #check signature
    sig = params[:sig].to_s
    params_string = ''

    if !request.request_parameters.nil? and !request.request_parameters.empty? 
      request.request_parameters.keys.sort.each do |key|
        if key != 'sig'
          params_string += key.to_s + '=' + params[key].to_s
        end
      end
    end

    response = {}

    # check application settings
    if sig.nil? or sig.empty? or sig.length != 32 or 
      params[:app_id].to_s != MEGABALL_IFRAME_CONFIG['vk']['id'].to_s or
      sig != Digest::MD5.hexdigest(params_string + MEGABALL_IFRAME_CONFIG['vk']['secret_key'].to_s)
        response[:error] = {
          error_code: 10,
          critical: true,
          error_msg: t(:incorrect_signature)
        }
    else
      payment_options = MEGABALL_CONFIG['payment']['vk']

      case params[:notification_type].to_s
      when 'get_item', 'get_item_test' then
        item_data = parse_item params[:item]

        if !item_data or item_data.empty? or item_data[:currency] == 'offer'
          response[:error] = {
            error_code: 20,
            error_msg: t(:undefined_product),
            critical: true 
          }
        else

          currencies = AcidCurrency.current 'vk'

          # If undefined currencies in db
          if currencies[:real].nil? or currencies[:imagine].nil?
            response[:error] = {
              error_code: 20,
              error_msg: t(:undefined_currency),
              critical: true 
            }
          else

            currency_type = item_data[:currency] == 'star' ? :real : :imagine

            if !check_exists_bonuses item_data, payment_options, currency_type
              response[:error] = {
                error_code: 20,
                error_msg: t(:undefined_product),
                critical: true
              }
            else
              response[:response] = {
                item_id: params[:item],
                title: "#{(item_data[:bonus] + item_data[:amount]).to_s} #{t(item_data[:currency], count: item_data[:amount] + item_data[:bonus])}",
                photo_url: ActionController::Base.helpers.asset_path(request.protocol + ActionController::Base.asset_host + '/assets/' + 'vk_' + item_data[:currency] + '.png'),
                price: AcidCurrency.calculate_price(item_data[:amount], item_data[:currency] == 'star' ? currencies[:real] : currencies[:imagine]),
                expiration: 3600
              }
            end
          end
        end
      when 'order_status_change', 'order_status_change_test' then
        if params[:status] == 'chargeable'
          item_data = parse_item((!params[:item_id].nil? and !params[:item_id].empty?) ? params[:item_id] : params[:item])

          mongo_user = User.where('oauth_providers.provider' => 'vkontakte', 'oauth_providers.uid' => ApplicationHelper.check_int_param(params[:user_id]).to_s).first

          acid_user = nil

          AcidPaymentTransaction.transaction do
            if mongo_user
              acid_user = AcidUser.find(mongo_user._id, lock: true)
            end

            if acid_user.nil?
              response[:error] = {
                error_code: 22, 
                error_msg: t(:undefined_user), 
                critical: true 
              }
            else
              if !item_data or item_data.empty?
                response[:error] = {
                  error_code: 20, 
                  error_msg: t(:undefined_product), 
                  critical: true 
                }
              else
                currencies= AcidCurrency.current 'vk'

                if currencies[:real].nil? or currencies[:imagine].nil?
                  response[:error] = {
                    error_code: 20, 
                    error_msg: t(:undefined_currency), 
                    critical: true 
                  }
                else

                  if Rails.env.release? and params[:notification_type].to_s == 'order_status_change_test'
                    response[:response] = {
                      order_id: params[:order_id].to_i, 
                      app_order_id: 1, 
                    }
                  else
                    transaction_id = nil

                    case item_data[:currency]
                    when 'offer'
                      current_currency = currencies[:real]
                      calculated_price = ApplicationHelper.check_int_param(params[:item_price])
                      calculated_amount = AcidCurrency.calculate_amount calculated_price, current_currency
   
                      transaction = AcidPaymentTransaction.new date: DateTime.now, gate_currency_amount: calculated_price, our_currency_amount: calculated_amount, bonus: 0, additional: {special_offer: true, offer: params[:item], vk_order_id: ApplicationHelper.check_int_param(params[:order_id])}.as_json
                      transaction.acid_user = acid_user
                      transaction.acid_currency = current_currency
                      transaction.save!

                      if !acid_user.payment :real, calculated_amount
                        raise ActiveRecord::Rollback, "User currency update problem"
                      end

                      transaction_id = transaction.id
                      
                    when 'coin', 'star' then

                      currency_type = item_data[:currency] == 'star' ? :real : :imagine

                      if !check_exists_bonuses item_data, payment_options, currency_type
                        response[:error] = {
                          error_code: 101,
                          error_msg: t(:incorrect_bonus) , 
                          critical: true,
                        }
                      else

                        current_currency = currencies[currency_type]
                        calculated_price = AcidCurrency.calculate_price item_data[:amount], current_currency

                        if calculated_price == params[:item_price].to_i
                          transaction = AcidPaymentTransaction.new date: DateTime.now, gate_currency_amount: calculated_price, our_currency_amount: item_data[:amount], bonus: item_data[:bonus], additional: {vk_order_id: ApplicationHelper.check_int_param(params[:order_id]), item_title: params[:item_title]}.as_json
                          transaction.acid_user = acid_user
                          transaction.acid_currency = current_currency
                          transaction.save!

                          if !acid_user.payment currency_type, item_data[:amount], item_data[:bonus]
                            raise ActiveRecord::Rollback, "User currency update problem"
                          end

                          StatsWorker.perform_for_user(mongo_user, :payment, {
                            item: currency_type,
                            social_network: 'vkontakte',
                            quantity: (item_data[:amount] + item_data[:bonus]),
                            custom: {amount: item_data[:amount], bonus: item_data[:bonus]}
                          })

                          transaction_id = transaction.id
                        else
                          response[:error] = {
                            error_code: 101,
                            error_msg: t(:incorrect_price),  
                            critical: true       
                          }       
                        end  
                      end                    
                    else
                      response[:error] = {
                        error: 101,
                        error_msg: t(:unknown_currency),
                        critical: true
                      }
                    end

                    if transaction_id
                      response[:response] = {
                        order_id: ApplicationHelper.check_int_param(params[:order_id]),
                        app_order_id: transaction_id 
                      }
                    else
                      response[:error] = {
                        error_code: 102,
                        error_msg: t(:server_transaction_error),
                        critical: true            
                      }
                    end
                  end
                end
              end
            end
          end
        else
          response[:error] = {
            :error_code => 100, 
            :error_msg => t(:incorrect_payment_status), 
            :critical => true 
          }
        end
      else
        response[:error] = {
          error_code: 100, 
          error_msg: t(:incorrect_chargeable), 
          critical: true 
        }
      end
    end

    render json: response
  end
end
