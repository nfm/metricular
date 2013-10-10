# Creates the database table plus indexes you'll need to use Metricular
class CreateMetrics < ActiveRecord::Migration
  def self.up
    create_table :metrics, force: true do |t|
      t.string :name
      t.date :date
      t.string :value
      t.timestamps
    end

    add_index :metrics, :name
    add_index :metrics, [ :name, :date ]
  end

  def self.down
    drop_table :metrics
  end
end
