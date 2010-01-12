require 'rubygems'
gem 'sinatra-sinatra'
require 'sinatra'
require 'dm-core'
require 'dm-is-tree'
require 'dm-types'
require 'dm-tags'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-serializer'
require 'sanitize'
require 'haml'
require 'sass'
require 'date'
require 'extensions/bbcode.rb'
load 'extensions/forum.rb'
load 'extensions/status.rb'
load 'extensions/auth.rb'


configure do
DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3:./my.db')

DataMapper.auto_upgrade!
end

before do
  if authorized?
  @user = User.get(session[:uid])
  @user.update(:last_active => DateTime.now)
  end
  logout! if @user == nil
end

enable :sessions
set :environment, :development
set :public, "./public"

get '/css/theme' do
  content_type 'text/css', :charset => 'utf-8'
  style = @user.style.to_s unless @user == nil
  if authorized?
    case style
      when "default" then sass :style_default
      when "compact" then sass :style_inverted
    end
  else sass :style_default
  end
  
end

get '/css/boxy' do
  content_type 'text/css', :charset => 'utf-8'
  sass :boxy
end

get '/' do
  @date = DateTime.now.strftime("%D")
  haml :index
end


