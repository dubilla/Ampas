class CreateAwardCeremonies < ActiveRecord::Migration
  def change
    create_table :award_ceremonies do |t|
      t.text :name
      t.timestamps null: false
    end
  end
end
