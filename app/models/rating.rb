class Rating < ApplicationRecord
  belongs_to :content
  belongs_to :user

  validates :stars, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 5
  }
  validates :user_id, uniqueness: { scope: :content_id }
end
