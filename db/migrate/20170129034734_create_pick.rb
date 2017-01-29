class CreatePick < ActiveRecord::Migration
  def change
    create_table :picks do |t|
      t.references :entry, foreign_key: true
      t.references :nominee, foreign_key: true

      t.timestamps null: false
    end
  end
end
