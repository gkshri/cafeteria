class AddCategoryRefToProducts < ActiveRecord::Migration[5.0]
  def change
    add_reference :products, :category, foreign_key: true, on_delete: :cascade
  end
end
