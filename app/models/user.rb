class User < ApplicationRecord

  # Relationships
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship",
            foreign_key: "follower_id", dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship",
            foreign_key: "followed_id", dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  # Attributes
  attr_accessor :remember_token, :activation_token, :reset_token

  # Callbacks
  before_save :downcase_email
  before_create :create_activation_digest

  # Validations
  validates :name, presence:true, length: {maximum:50}
   VALID_EMAIL_REGEX =  /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence:true, length: {maximum:255},
             format: {with:VALID_EMAIL_REGEX},
             uniqueness:{case_sensitive:false}
  has_secure_password
  validates :password, presence:true, length: {minimum:6}, allow_nil:true

  # Methods

  # Return hash object generated with string
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Return random token
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remember digested token in database for permanent session
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # If token matches digested token in database, return true
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest") # attribute can be remember, activation, or reset
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Remove login info
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Activate account
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # Send email for account activation
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Set password reset digest
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  # Send email for password reset
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # If reset token is expired, return true
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # Get user's status feed
  def feed
    following_ids = "SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
  end

  # Follow other user
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
    if other_user.follow_notification
      Relationship.send_follow_email(other_user, self)
    end
  end

  # Unfollow other user
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
    if other_user.follow_notification
      Relationship.send_unfollow_email(other_user, self)
    end
  end

  # If user follow the other user, return true
  def following?(other_user)
    following.include?(other_user)
  end

  private

    # Change email address to lowercase
    def downcase_email
      email.downcase!
    end

    # Generate activation token and digest the token
    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
