class CreatePools < ActiveRecord::Migration
  def change
    create_table :pools do |t|
      t.references :award_ceremony, foreign_key: true

      t.timestamps null: false
    end
  end
end
