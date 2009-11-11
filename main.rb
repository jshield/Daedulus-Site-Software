require 'rubygems'
gem 'sinatra-sinatra'
require 'sinatra'
require 'dm-core'
require 'dm-is-tree'
require 'dm-types'
require 'dm-tags'
require 'haml'
require 'sass'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3:./my.db')
load 'models/forum.rb'
DataMapper.auto_upgrade!

enable :session
set :environment, :development
set :public, "./public"

get '/css/a' do
  content_type 'text/css', :charset => 'utf-8'  
  sass :a
end

get '/run-tests' do

  user = User.create(:name => "James Alexander Shield", :email => "test@test.dan", :password => "testpass")
  user.post.create(:title => "Test Post", :body => "Test Body")
  user.save

end

get '/css/yui' do
  content_type 'text/css', :charset => 'utf-8'
  sass :yui_reset
end

get '/' do
  @date = DateTime.now.strftime("%D")
  haml :index
end

get '/forum' do
  @posts = Post.last(5)
  haml :forum_index
end
