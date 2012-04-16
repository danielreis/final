class CreateSensors < ActiveRecord::Migration
  def change
    create_table :sensors do |t|
      t.string :sensor_name
      t.text :context
      t.string :queue_name
      t.string :routing_key
      t.string :sensor_info
      t.references :user

      t.timestamps
    end
    add_index :sensors, :user_id
  end
end
