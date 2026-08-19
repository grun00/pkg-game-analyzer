class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  enum :role, { regular: 0, content_creator: 1 }, prefix: true

  has_many :dashboards, dependent: :destroy
  has_many :matches, through: :dashboards
end
