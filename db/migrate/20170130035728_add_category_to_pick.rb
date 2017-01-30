class AddCategoryToPick < ActiveRecord::Migration
  def change
    add_reference :picks, :category, index: true
  end
end
