class CreateFlightsRecord < ActiveRecord::Migration[7.0]
  def change
    create_table :flights do |t|
      t.string :drone_registration_id, null: false
      t.string :pilot_id, null: false
      t.decimal :take_off_latitude, precision: 10, scale: 6
      t.decimal :take_off_longitude, precision: 10, scale: 6
      t.decimal :landing_latitude, precision: 10, scale: 6
      t.decimal :landing_longitude, precision: 10, scale: 6
      t.datetime :take_off_time
      t.datetime :landing_time
      t.timestamps
    end
  end
end
