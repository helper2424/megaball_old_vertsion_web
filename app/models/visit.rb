class Visit
	include Mongoid::Document
	
	field :user_id, type: Integer
	field :time_in, type: Integer
	field :time_out, type: Integer
end
