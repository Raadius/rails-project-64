class Post < ApplicationRecord
  belongs_to :category
  belongs_to :creator, class_name: 'User'
  has_many :post_comments, dependent: :destroy
  has_many :post_likes, dependent: :destroy
  has_many :liked_by_users, through: :post_likes, source: :user

  validates :title, presence: true, length: { minimum: 5, maximum: 255 }
  validates :body, presence: true, length: { minimum: 200, maximum: 4000 }
end
