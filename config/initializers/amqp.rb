require "rubygems"
require "amqp"


Thread.new { EM.run do
  
  AMQP.connect(:host => "192.168.1.84", :port => 10000, :user => "guest", 
              :pass => "guest", :vhost => "/") do |connection|
     ch  = AMQP::Channel.new(connection)
     $AMQP_CH = ch
     puts "ch: " + ch.to_s

 end

end
}

