# To change this template, choose Tools | Templates
# and open the template in the editor.

class User
  include DataMapper::Resource

  property :id, Serial
  property :uname, String, :nullable => false
  property :name, String, :nullable => false,
  :messages => {
                :presence => "We need a display name.",
                :is_unique => "We already have someone by that name."
               }
  property :email, String, :nullable => false,  :format => :email_address,
  :messages => {
                :presence => "We need your email address.",
                :is_unique => "We already have that email.",
                :format => "Doesn't look like an email address to me ..."
               }

  property :password, BCryptHash,
  :messages => {
                :presence => "You need to provide a password",
                :length => "Password is too short needs to be at least 8 characters long"
               }
  property :custom_title, Text
  property :post_count, Integer
  property :sig, Text
  property :sex, Enum[ :male, :female, :intersex, :undefined ], :default => :undefined
  property :dob, Date
  property :created_at, DateTime
  property :last_active, DateTime
  property :flags, Flag[ :activated, :banned ] 
  property :permissions, Flag[ :admin, :moderator, :tagman ]

  has n, :post
  
  validates_is_unique :uname
  validates_is_unique :email
  validates_is_unique :name
  validates_present :password
  validates_length :password, :min => 8



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

class Event
  include DataMapper::Resource
  
  property :id, Serial
  property :created_at, DateTime
  property :content, Text
  
end

class Message
  include DataMapper::Resource
  
  property :id, Serial
  property :created_at, DateTime
  property :sender, Integer
  property :sendee, Integer
  property :message, Text
  
  validates_present :message
  validates_present :sender
  validates_present :sendee
  
end

