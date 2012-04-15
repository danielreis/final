require "rubygems"
require "amqp"

class SensorsController < ApplicationController
  
  def publish(message, queueName)
   EventMachine.run do
    AMQP.start("amqp://127.0.0.1:5672") do |connection|
      
        channel  = AMQP::Channel.new(connection)
        queue    = channel.queue(queueName, :auto_delete => false)
        exchange = channel.direct("")
         EventMachine.add_timer(2) do

        exchange.publish message, :routing_key => queue.name
      end
      
      # disconnect & exit after 2 seconds
      EventMachine.add_timer(2) do
      # exchange.delete
       connection.close { EventMachine.stop }
      end
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

     # For URL like /users/1/sensors
     # Populate an item associate with order 1 with form data
     # User will be associated with the item
     @sensor = @user.sensors.build(params[:sensor])
     if @sensor.save
       publish(@sensor.attributes, @sensor.queue_name)
       # Save the item successfully
       redirect_to user_sensor_url(@user, @sensor)
       
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
       publish(@sensor.attributes, @sensor.queue_name)
       
       # Save the item successfully
       redirect_to user_sensors_path
     else
       render :action => "edit"
     end
   end

   # DELETE /User/1/sensors/2
   def destroy
     @user = User.find(params[:user_id])
     @sensor = Sensor.find(params[:id])
     @sensor.destroy

     respond_to do |format|
       format.html { redirect_to user_sensors_path(@user) }
       format.xml  { head :ok }
     end
   end

end
