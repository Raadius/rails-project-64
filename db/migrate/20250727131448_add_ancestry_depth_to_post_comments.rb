class AddAncestryDepthToPostComments < ActiveRecord::Migration[7.2]
  def change
    add_column :post_comments, :ancestry_depth, :integer
  end
end
