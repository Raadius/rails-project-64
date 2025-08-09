class User < ApplicationRecord
  has_many :posts, foreign_key: 'creator_id', inverse_of: :creator, dependent: :destroy
  has_many :post_likes, dependent: :destroy
  has_many :liked_posts, through: :post_likes, source: :post
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
