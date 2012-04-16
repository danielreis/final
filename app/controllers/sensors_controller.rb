require "rubygems"
require "amqp"

class SensorsController < ApplicationController
  
  # "amqp://127.0.0.1:5672"
  def publish(host, exch_name, rout_key, queue_name, message)
    EventMachine.run do
       
       AMQP.connect(host) do |connection|
         channel  = AMQP::Channel.new(connection)
         exchange = channel.topic(exch_name)
         
         # publish updates 1 second later, after all queues are declared and bound
        EventMachine.add_timer(1) do
          # we may publish multiple messages for multiple routing_keys under the same topic
             exchange.publish(message, :routing_key => rout_key)
        end

        show_stopper = Proc.new { connection.close { EventMachine.stop } }
        Signal.trap "TERM", show_stopper
        EM.add_timer(1, show_stopper)
      end
    end
  end

  # GET /users/1/items
   def index
     # For URL like /users/1/sensors
     # Get the user with id=1
     @user = User.find(params[:user_id])

     # Access all items for that order
     @sensors = @user.sensors
   end

   # GET /users/1/sensors/2
   def show
     @user = User.find(params[:user_id])

     # For URL like /users/1/sensors/2
     # Find a sensor in users 1 that has id=2
     @sensor = @user.sensors.find(params[:id])
   end

   # GET /users/1/sensors/new
   def new
     @user = User.find(params[:user_id])
     @sensor = @user.sensors.build
     @users = User.find(:all)
   end

   # POST /users/1/sensors
   def create
     @user = User.find(params[:user_id])
     @users = User.find(:all)
     # For URL like /users/1/sensors
     # Populate an item associate with order 1 with form data
     # User will be associated with the item
     @sensor = @user.sensors.build(params[:sensor])
     if @sensor.save
      
       publish("amqp://127.0.0.1:5672", @user.exchange_name, @sensor.routing_key, @sensor.queue_name, @sensor.attributes)
       # Save the item successfully
       redirect_to user_sensors_path
       
     else
       render :action => "new"
     end
   end

   # GET /users/1/sensors/2/edit
   def edit
     @user = User.find(params[:user_id])
     @users = User.find(:all)
     # For URL like /users/1/sensors/2/edit
     # Get item id=2 for order 1
     @sensor = @user.sensors.find(params[:id])
   end

   # PUT /users/1/sensors/2
   def update
     @user = User.find(params[:user_id])
     @sensor = Sensor.find(params[:id])
     if @sensor.update_attributes(params[:sensor])
           publish("amqp://127.0.0.1:5672", @user.exchange_name, @sensor.routing_key, @sensor.queue_name, @sensor.attributes)
       
       # Save the item successfully
       redirect_to user_sensors_path
     else
       render :action => "edit"
     end
   end

   # DELETE /User/1/sensors/2
   def destroy
    
     @sensor = Sensor.find(params[:id])
     @sensor.destroy

     respond_to do |format|
       format.html { redirect_to user_sensors_path(@user) }
       format.xml  { head :ok }
     end
   end

end