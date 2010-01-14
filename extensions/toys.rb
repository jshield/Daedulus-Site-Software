require 'sinatra/base'

module Sinatra
	module Shoot
		module Helpers
	    def shoot(tid,wid)
        target = User.get(tid)
        weapon = Weapon.get(wid)
        eventmsg(session[:uid],"#{weapon.action} #{target.profile_link} with a #{weapon.name}.")  
      end
      
      def addweapon(name,action)
        nweapon = Weapon.create(:name => name,:action => action)
        nweapon.save
      end
      
      def select_weapon()
        select = "<select name=\"wid\">"
        Weapon.all.each do |w|
        select << "<option value = \"#{w.id}\">#{w.name}</option>"
        end
        select << "</select>"
        return select
      end
		end
	
	def self.registered(app)
		app.helpers Shoot::Helpers
		
		app.get '/api/shootuser/:tid' do
		  haml :shoot_user if authorized?
		end
		
		app.post '/api/shootuser' do		
		  shoot(params[:tid],params[:wid]) if authorized?
		end
		
		app.get '/api/addweapon' do
		  haml :shoot_addweapon if authorized?
		end
		
		app.post '/api/addweapon' do
		  addweapon(params[:name],params[:action]) if authorized?
		end
		
	end	
	end
	register Shoot
end

class Weapon
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  property :action, String
  
  has n, :attacks
  has n, :users, :through => :attacks
  
  validates_present :name
  validates_present :action
  
end

class Attack
  include DataMapper::Resource
  
  property :id, Serial
  property :target, Integer
  
  belongs_to :weapon
  belongs_to :user
  
end
