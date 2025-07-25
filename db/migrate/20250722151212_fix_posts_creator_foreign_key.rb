class FixPostsCreatorForeignKey < ActiveRecord::Migration[7.2]
  def change
    # Remove the incorrect foreign key constraint
    remove_foreign_key :posts, :creators
    
    # Add the correct foreign key constraint pointing to users table
    add_foreign_key :posts, :users, column: :creator_id
  end
end
