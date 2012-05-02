require "rubygems"
require "amqp"


Thread.new { EM.run do
  
  AMQP.connect(:host => "127.0.0.1", :port => 10001, :user => "guest", 
              :pass => "guest", :vhost => "/") do |connection|
     ch  = AMQP::Channel.new(connection)
     $AMQP_CH = ch
     puts "ch: " + ch.to_s

 end

end
}

