class Micropost < ApplicationRecord
  belongs_to :user

  # Order
  default_scope -> {order(created_at: :desc)}

  # Uploader
  mount_uploader :picture, PictureUploader

  # Validations
  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: 140}
  validate :picture_size

  private

    # Check if size of uploaded image is more than 5MB
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end
end
