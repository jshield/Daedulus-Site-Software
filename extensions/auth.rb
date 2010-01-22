require 'sinatra/base'

module Sinatra
  module SessionAuth

    module Helpers
      def authorized?
        session[:authorized]
      end

      def authorize!
        redirect '/user/login' unless authorized?
      end

      def logout!
        session[:authorized] = false
        session[:uid] = nil
      end
    end
    
    def self.registered(app)
      app.helpers SessionAuth::Helpers
      
      app.post '/user/logout' do
        logout!
      end
      
      app.get '/user/error/:reason' do
          case params[:reason]
            when "user" then "Unknown User"
            when "pass" then "Wrong Password"
            when "register" then "Failure in registeration"
            else "Unknown Error!"
          end
      end
    
      app.post '/api/login' do
          user = User.first(:uname => params[:user])
          unless user == nil 
            if user.password == params[:pass]
              session[:authorized] = true
              session[:uid] = user.id
            else
              session[:authorized] = false
            end
        else
          session[:authorized] = false
        end
      end
    
    
      app.get '/api/login' do
        haml :user_login unless authorized?
      end  
    
      app.get '/api/register' do
        haml :register_form
      end
          
      app.post '/api/register' do
        newuser = User.create(:uname => params[:user], :name => params[:disp], :email => params[:email], :password => params[:pass])
        if newuser.valid?
          newuser.save
          eventmsg(newuser,"joined Daedulum Novae.")
        end
      end
      
      app.get '/api/password' do
        haml :password_form if authorized?
      end
      
      app.post '/api/password' do
        @user.update_attributes(:password => params["pass"]) if @user.password == params["oldpass"]
      end
      
     app.get '/user/list' do
      output = "Users in System<br>"
      User.all.each do |user|
      output = output + user.id.to_s + " " + user.name + "<br>"
      end
      
       output
    end
    
    app.get '/api/message' do
  		haml :message_center if authorized?
		end

		app.get '/api/userbox' do
  		haml :userbox
		end
        
    app.get '/api/user/profile/haml/:uid' do |u|
      if authorized?
        @user = User.get!(u)
        haml :user_profile
      else
      
      end
    end
    
  end
end

  register SessionAuth
end

class User
  include DataMapper::Resource

  property :id, Serial
  property :uname, String, :required => true
  property :name, String, :required => true,
  :messages => {
                :presence => "We need a display name.",
                :is_unique => "We already have someone by that name."
               }
  property :email, String, :required => true,  :format => :email_address,
  :messages => {
                :presence => "We need your email address.",
                :is_unique => "We already have that email.",
                :format => "Doesn't look like an email address to me ..."
               }

  property :password, BCryptHash,
  :messages => {
                :presence => "You need to provide a password",
                :length => "Password is too short needs to be at least 8 characters long"
               }

  property :style, Enum[ :default, :compact ], :default => :default
  property :color, Enum[ :default, :inverted ], :default => :default
  property :created_at, DateTime
  property :last_active, DateTime
  property :flags, Flag[ :activated, :banned ] 
  property :permissions, Flag[ :admin, :moderator, :tagman ]
  property :custom_title, Text
  property :sig, Text
  property :sex, Enum[ :male, :female, :intersex, :undefined ], :default => :undefined
  property :dob, Date


  has n, :post
  has n, :message
  has n, :status
  has n, :attacks
  has n, :weapons, :through => :attacks
  
  validates_is_unique :uname
  validates_is_unique :email
  validates_is_unique :name
  validates_present :password
  validates_length :password, :min => 8

  def link
    return "<a href=\"#\" class=\"profile\" onclick=\"loadProfile(#{self.id})\">#{self.name}</a>"
  end
  
  def curstatus
    if self.status.last(:type => :personal) != nil
    status = self.status.last(:type => :personal).body
    else
    status = "has not set a status message."
    end
    return status  
  end
  
end

class Message
  include DataMapper::Resource
  
  property :id, Serial
  property :created_at, DateTime
  property :sendee, Integer
  property :message, Text
  
  belongs_to :user
  
  validates_present :message
  validates_present :sender
  validates_present :sendee
  
end
