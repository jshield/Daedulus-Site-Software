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
    
    	def eventmsg(id,msg)    	
    	event = Status.create(:user_id => id, :type => :event, :body => msg)
    	event.save    	
    	end
    
    end
    
    def self.registered(app)
    	app.helpers UserStatus::Helpers
		
			app.get '/api/status' do
 				haml :status_form
			end

			app.get '/api/status/list' do
				@status = Status.all.reverse
				haml :status_list
			end

			app.post '/api/status' do
				body = Sanitize.clean(params[:body]).gsub("&#13;","")
				status = Status.create(:user_id => session[:uid], :body => body)
				status.save	
			end
		end
	end		
  register UserStatus
end

