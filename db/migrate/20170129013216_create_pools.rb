class CreatePools < ActiveRecord::Migration[4.2]
  def change
    create_table :pools do |t|
      t.references :award_ceremony, foreign_key: true

      t.timestamps null: false
    end
  end
end
