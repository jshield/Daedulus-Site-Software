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

get '/debug/run-tests' do
  user = User.create(:name => "James Alexander Shield", :email => "test@test.dan", :password => "testpass")
  post = user.post.create(:title => "Test Post", :body => "Test Body")
  post.children.create(:title => "Test Reply", :body => "Test Reply Body", :user_id => user.id)
  user.save
end

get '/debug/reset-database' do
  DataMapper.auto_migrate!
end

get 'debug/dump-database' do

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
  puts p
  @posts = Post.get(p)
  unless @posts == nil
  @child = true
  @posts = @posts.to_a + @posts.children.to_a
    haml :forum_index
  else
   redirect "/forum/"
  end
end
