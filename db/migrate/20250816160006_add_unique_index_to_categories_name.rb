# frozen_string_literal: true

class AddUniqueIndexToCategoriesName < ActiveRecord::Migration[7.2]
  def change
    add_index :categories, :name, unique: true
  end
end
