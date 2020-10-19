class User < ApplicationRecord
  has_many :reviews
  has_many :applications

  def best_review
    reviews.order(rating: :desc).limit(1).first
  end

  def worst_review
    reviews.order(:rating).limit(1).last
  end

  def full_address
    "#{self.street_address} #{self.city}, #{self.state} #{self.zip}"
  end
end
