class CreateMonitoringAlerts < ActiveRecord::Migration[7.2]
  def change
    create_table :monitoring_alerts, if_not_exists: true do |t|
      t.references :person, null: false, foreign_key: true
      t.integer :kind, null: false
      t.decimal :amount, precision: 15, scale: 2
      t.integer :status, null: false, default: 0
      t.datetime :reference_at, null: false

      t.timestamps
    end

    add_index :monitoring_alerts, :kind, if_not_exists: true
    add_index :monitoring_alerts, :status, if_not_exists: true
    add_index :monitoring_alerts, :reference_at, if_not_exists: true
  end
end
