class CreateAwardCeremonies < ActiveRecord::Migration[4.2]
  def change
    create_table :award_ceremonies do |t|
      t.text :name
      t.timestamps null: false
    end
  end
end
