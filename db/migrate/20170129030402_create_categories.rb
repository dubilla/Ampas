class CreateCategories < ActiveRecord::Migration[4.2]
  def change
    create_table :categories do |t|
      t.text :name
      t.references :award_ceremony, foreign_key: true

      t.timestamps null: false
    end
  end
end
