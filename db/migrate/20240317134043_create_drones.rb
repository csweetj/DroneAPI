class CreateDrones < ActiveRecord::Migration[7.0]
  def change
    create_table :drones do |t|
      t.string :drone_registration_id, null: false, unique: true
      t.integer :total_flight_time, default: 0, null: false

      t.timestamps
    end
    add_index :drones, :drone_registration_id, unique: true
  end
end
