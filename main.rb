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
require 'bb-ruby'
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

post '/forum/post' do
  
  if authorized?
     title = Sanitize.clean(params[:title])
     body = Sanitize.clean(params[:body]).gsub("&#13;","")
     if (params[:upid] != nil)
      post = Post.get(params[:upid])
      post.update_attributes(:title => title, :body => body)
     else
      post = Post.create(:user_id => session[:uid], :title => title, :body => body)
      post.parent_id = params[:pid] if defined?(params[:pid])
    end
    if post.valid? 
      post.save
      redirect "/forum/post/#{post.root.id}"
    else
      redirect request.referer
    end
  else
    redirect request.referer
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
  @posts = Post.all.reverse
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

get '/api/post/delete/:pid' do |p|
   post = Post.get(p)
   if authorized? and post.user.id == session[:uid]
     post.children.each do |pt|
      if pt.id == post.children.first.id
        repository(:default).adapter.query("UPDATE posts SET parent_id=NULL WHERE id = #{pt.id}")  
      else
        repository(:default).adapter.query("UPDATE posts SET parent_id=#{post.children.first.id} WHERE id = #{pt.id}") 
      end        
     end
     post = Post.get(p)
     post.destroy
    "Post #{p} deleted"
   end
end

get '/api/post/update/form/:pid' do |p|
  if authorized?
    @post = Post.get(p)
    haml :update_form
  else
    "<span>Not Authorized!</span>"
  end
end

get '/api/post/quote/form/:pid' do |p|
  @quote = Post.get(p)
  haml :quote_form

end

