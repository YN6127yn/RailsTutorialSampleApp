class Relationship < ApplicationRecord

  # Relations
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  # Validations
  validates :follower_id, presence: true
  validates :followed_id, presence: true

  # Methods

  # Send email for follow notification
  def Relationship.send_follow_email(user, follower)
    RelationshipMailer.follow_notification(user, follower).deliver_now
  end

  # Send email for unfollow notification
  def Relationship.send_unfollow_email(user, follower)
    RelationshipMailer.unfollow_notification(user, follower).deliver_now
  end
end
