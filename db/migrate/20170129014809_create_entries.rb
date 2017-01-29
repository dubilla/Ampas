class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.references :pool, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps null: false
    end
  end
end
