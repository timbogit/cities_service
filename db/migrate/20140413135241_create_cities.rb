class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :name
      t.string :state
      t.string :country
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
    add_index :cities, [:name, :state, :country], unique: true
  end
end
