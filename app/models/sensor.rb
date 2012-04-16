class Sensor < ActiveRecord::Base
  belongs_to :user
  
  validates :sensor_name, :presence => true, :uniqueness => true, :length => { :maximum => 100 }
  validates :routing_key, :presence => true, :uniqueness => true
end
