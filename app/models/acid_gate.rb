class AcidGate < ActiveRecord::Base
  self.table_name = 'gates'

  attr_accessible :name
end
