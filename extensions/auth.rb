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
      end
    end

    def self.registered(app)
      app.helpers SessionAuth::Helpers

      app.get '/user/login' do
        "<form method='POST' action='/user/login'>" +
        "<input type='text' name='user'>" +
        "<input type='password' name='pass'>" +
        "</form>"
      end
      
      app.get '/user/logout' do
        logout!
        redirect request.referer
      end
      
      app.get '/user/error/:reason' do
          case params[:reason]
            when "user" then "Unknown User"
            when "pass" then "Wrong Password"
            else "Unknown Error!"
          end
      end

      app.post '/user/login' do
          user = User.first(:uname => params[:user])
          unless user == nil
            puts params[:pass]
            if user.password == params[:pass]
              session[:authorized] = true
              session[:uid] = user.id
              redirect request.referer
            else
            redirect '/user/error/pass'
            end
        else
          session[:authorized] = false
          redirect '/user/error/user'
        end
      end
    end
  end

  register SessionAuth
end
