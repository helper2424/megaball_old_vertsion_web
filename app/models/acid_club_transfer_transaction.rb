class AcidClubTransferTransaction < ActiveRecord::Base
  self.table_name = 'club_transfer_transactions'

  belongs_to :acid_user, foreign_key: "user_id"
  belongs_to :acid_club, foreign_key: "club_id"

  attr_accessible :date, 
                  :transfer_type, # 0 - direct, 1 - reverse
                  :amount

  default_scope { order("date DESC") }
end
