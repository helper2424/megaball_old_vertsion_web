module RouletteHelper
  def check_roulette_tickets!
    user = current_user
    if user.last_roulette_ticket_given < Time.now.beginning_of_day
      user.last_roulette_ticket_given = Time.now
      user.roulette_tickets += 1
      user.save
    end
  end
end
