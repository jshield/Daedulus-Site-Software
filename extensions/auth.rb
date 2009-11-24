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
            puts params[:pass]
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
