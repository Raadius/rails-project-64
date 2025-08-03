class Post < ApplicationRecord
  belongs_to :category
  belongs_to :creator, class_name: 'User'
  has_many :post_comments, dependent: :destroy

  validates :title, presence: true, length: { minimum: 5, maximum: 255 }
  validates :body, presence: true, length: { minimum: 200, maximum: 4000 }
end
