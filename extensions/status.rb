require 'sinatra/base'


class Status
	include DataMapper::Resource
	
	property :id, Serial
	property :created_at, DateTime
	property :body, Text, :length => 500
	property :type, Enum[ :personal, :event, :private ], :default => :personal
	
	belongs_to :user
	
	validates_present :body

end

module Sinatra
	module UserStatus
		module Helpers
    
    	def eventmsg(user, msg)     	  	
    	  event = user.status.create(:type => :event, :body => msg)
    	  event.save    	
    	end    
    
    end
    
    def self.registered(app)
    	app.helpers UserStatus::Helpers
		
			app.get '/api/status' do
 				haml :status_form
			end

			app.get '/api/status/list' do
				haml :status_list
			end

			app.post '/api/status' do
				body = Sanitize.clean(params[:body]).gsub("&#13;","")
				@user.status.create(:body => body)
			end
		end
	end		
  register UserStatus
end

