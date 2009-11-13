require 'rubygems'
gem 'sinatra-sinatra'
require 'sinatra'
require 'dm-core'
require 'dm-is-tree'
require 'dm-types'
require 'dm-tags'
require 'dm-timestamps'
require 'haml'
require 'sass'
require 'date'
require 'extensions/auth.rb'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3:./my.db')
load 'models/forum.rb'
DataMapper.auto_upgrade!

before do
  if authorized?
  @user = User.get(session[:uid])
  end
end

enable :sessions
set :environment, :development
set :public, "./public"

get '/css/a' do
  content_type 'text/css', :charset => 'utf-8'  
  sass :a
end

get '/debug/run-tests' do
  user = User.create(:name => "James Alexander Shield", :uname => "test", :email => "test@test.dan", :password => "testpass")
  post = user.post.create(:title => "Test Post", :body => "Test Body")
  post.children.create(:title => "Test Reply", :body => "Test Reply Body", :user_id => user.id)
  user.save
end

post '/forum/post' do
 Post.create(:title => params[:title], :body => params[:body])    
end

post '/forum/reply/:pid' do

end

get '/debug/reset-database' do
  DataMapper.auto_migrate!
end

get 'debug/dump-database' do

end

get '/debug/auth' do
  if authorized?
    "Authorized!"
  else
    "Access Denied!"
  end  
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
  @posts = Post.roots.last(5)
  haml :forum_index
end

get '/forum/post/:pid' do |p|
  @posts = Post.get(p)
  unless @posts == nil
  @posts = @posts.to_a + @posts.children.to_a
    haml :forum_post
  else
   redirect "/forum/"
  end
end
