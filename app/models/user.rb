class User < ApplicationRecord
  has_many :posts, foreign_key: 'creator_id', inverse_of: :creator, dependent: :destroy
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
