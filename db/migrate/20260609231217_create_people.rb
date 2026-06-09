class CreatePeople < ActiveRecord::Migration[7.2]
  def change
    create_table :people, if_not_exists: true do |t|
      t.string :name, null: false
      t.string :document, null: false

      t.timestamps
    end

    add_index :people, :document, unique: true, if_not_exists: true
  end
end
