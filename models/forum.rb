# To change this template, choose Tools | Templates
# and open the template in the editor.

class User
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :nullable => false
  property :email, String, :nullable => false
  property :password, BCryptHash
  property :sig, Text
  property :created_at, DateTime
  property :last_active, DateTime
  property :permissions, Flag[ :admin, :moderator, :tagman ]

  has n, :post


end

class Post
  include DataMapper::Resource

  property :id, Serial
  property :parent_id, Integer
  property :title, String
  property :body, Text
  property :created_at, DateTime

  belongs_to :user
  is :tree, :order => :id
  has_tags_on :tags
end

