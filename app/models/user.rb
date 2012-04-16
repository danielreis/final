class User < ActiveRecord::Base  
  has_many :sensors
  
  validates :first_name, :presence => true, :length => { :maximum => 100 }
  validates :exchange_name, :presence => true, :uniqueness => true 
end
