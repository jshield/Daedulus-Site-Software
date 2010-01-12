
class Status
	include DataMapper::Resource
	
	property :id, Serial
	property :created_at, DateTime
	property :body, String
	
	belongs_to :user
	
	validates_present :body

end

get '/api/status' do
 haml :status_form
end

get '/api/status/list' do
	@status = Status.all.reverse
	haml :status_list
end

post '/api/status' do
	body = Sanitize.clean(params[:body]).gsub("&#13;","")
	newstatus = Status.create(:user_id => session[:uid], :body => body)
	newstatus.save	
end
