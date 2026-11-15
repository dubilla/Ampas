class CreatePick < ActiveRecord::Migration[4.2]
  def change
    create_table :picks do |t|
      t.references :entry, foreign_key: true
      t.references :nominee, foreign_key: true

      t.timestamps null: false
    end
  end
end
