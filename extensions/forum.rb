
#Models

class Post
  include DataMapper::Resource

  property :id, Serial
  property :parent_id, Integer
  property :title, String
  property :body, Text
  property :created_at, DateTime
  property :modified_at, DateTime
  belongs_to :user
  is :tree, :order => :id
  has_tags_on :tags
  
  validates_present :title
  validates_present :body
  
end

#Routes

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
   redirect "/forum"
  end
end

get '/api/post/delete/:pid' do |p|
   @post = Post.get(p)
   if authorized? and @post.user.id == session[:uid]
     if @post.children.any?
     @post.children.each do |pt|
      if pt.id == pt.root.children.first.id
        pt.update(:parent_id => nil)
        @pid = pt.id 
      else
        pt.update(:parent_id => @pid)
      end        
     end
     end
     @post.destroy
    "Post #{p} deleted"
   end
end

get '/api/reply/:pid' do |p|
  @post = Post.get!(p)
  if authorized?
    haml :reply_form
  else
  
  end  
end

get '/api/update/:pid' do |p|
  @post = Post.get!(p)
  if authorized? and @post.user.id == session[:uid]
    haml :update_form
  else
    "<span>Not Authorized!</span>"
  end
end

get '/api/post/list/haml/:pid' do |p|
  @posts = Post.get(p)
  @posts = @posts.root
  unless @posts == nil
  @posts = @posts.to_a + @posts.children.to_a
    haml :post_list
  else
  end
end

get '/api/topic/list/haml' do
  @postroots = Post.all(:order => [ :created_at.asc ])
  @posts = {}
  @postroots.each do |pt|
  if pt.children.any?
  @posts = @posts.to_a + pt.children.last.to_a
  elsif pt.children.empty? and pt.id == pt.root.id
  @posts = @posts.to_a + pt.root.to_a
  end
  end
  @posts = @posts.sort_by {|post| post.created_at}
  @posts = @posts.reverse
  haml :topic_list
end

get '/api/quote/:pid' do |p|
  if authorized?
    @quote = Post.get!(p)
    haml :quote_form
  else
     "<span>Not Authorized!</span>"
  end
end

get '/api/npst' do
  haml :topic_form if authorized?
end

['/api/npst','/api/quote','/api/reply', '/api/update'].each do |m|
  post m do
    if authorized?
       title = Sanitize.clean(params[:title])
       body = Sanitize.clean(params[:body]).gsub("&#13;","")
       if (params[:upid] != nil)
        post = Post.get(params[:upid])
        post.update(:title => title, :body => body)
       else
        post = Post.create(:user_id => session[:uid], :title => title, :body => body)
       if params[:pid] != nil
        post.parent_id = params[:pid] 
        parent = Post.get(params[:pid])
   			ebody = "replied to <a class=\"topic\" onclick=\"loadTopic(#{parent.id})\">#{parent.title}</a>"
   		 else
   		  ebody = "posted a topic called <a class=\"topic\" onclick=\"loadTopic(#{post.id});\">#{post.title}</a>"
   		 end
      end
      if post.valid? 
        post.save
        eventmsg(session[:uid],ebody)       
      end
    end
  end
end
