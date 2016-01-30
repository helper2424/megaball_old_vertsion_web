class TransfersController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :class => :transfers

  # POST /transfer/to_club
  def to_club
    amount = params[:amount].to_i
    result = {}

    if amount > 0
      AcidUser.transaction do
        acid_user = AcidUser.find(current_user._id)
        unless acid_user.can_pay_for?(currency, amount)
          result[:error] = :not_enough_money
          break
        end

        AcidClub.transaction do
          acid_club = AcidClub.find(current_user.club._id)

          acid_user.buy(currency, amount)
          acid_club.payment(currency, amount)

          transaction = AcidClubTransferTransaction.new(
            date: DateTime.now,
            transfer_type: 0,
            amount: amount)
          transaction.acid_user = acid_user
          transaction.acid_club = acid_club
          transaction.save!

          StatsWorker.perform_for_user(current_user, :transfer_to_club, {
            quantity: amount,
            item: currency,
            custom: { club_id: acid_club.id }
          })
        end
      end
    end

    render json: result
  end

  private

  def currency
    @currency ||= (params[:currency] == 'stars') ? :real : :imagine
  end

end
