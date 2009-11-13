# To change this template, choose Tools | Templates
# and open the template in the editor.

class User
  include DataMapper::Resource

  property :id, Serial
  property :uname, String, :nullable => false
  property :name, String, :nullable => false
  property :email, String, :nullable => false
  property :password, BCryptHash
  property :custom_title, Text
  property :post_count, Integer
  property :sig, Text
  property :sex, Enum[ :male, :female, :intersex, :undefined ], :default => :undefined
  property :dob, Date
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
  property :modified_at, DateTime
  belongs_to :user
  is :tree, :order => :id
  has_tags_on :tags
  
  validates_present :title
  validates_present :body
  
end

