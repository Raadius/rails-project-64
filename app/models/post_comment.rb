class PostComment < ApplicationRecord
  belongs_to :post
  belongs_to :user
  has_ancestry cache_depth: true, orphan_strategy: :rootify, ancestry_format: :materialized_path2

  validates :content, presence: true, length: { minimum: 5, maximum: 400 }
end
