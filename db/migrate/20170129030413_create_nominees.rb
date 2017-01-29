class CreateNominees < ActiveRecord::Migration
  def change
    create_table :nominees do |t|
      t.text :name
      t.references :category, foreign_key: true
    end
  end
end
