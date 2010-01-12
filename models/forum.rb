

class Status
	include DataMapper::Resource
	
	property :id, Serial
	property :created_at, DateTime
	property :body, String
	
	belongs_to :user
	
	validates_present :body

end

