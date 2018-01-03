class User < ApplicationRecord

  attr_accessor :remember_token, :activation_token

  # Call back
  before_save :downcase_email
  before_create :create_activation_digest

  # Validation
  validates :name, presence:true, length: {maximum:50}
   VALID_EMAIL_REGEX =  /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence:true, length: {maximum:255},
             format: {with:VALID_EMAIL_REGEX},
             uniqueness:{case_sensitive:false}
  has_secure_password
  validates :password, presence:true, length: {minimum:6}, allow_nil:true

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
    digest = send("#{attribute}_digest") # attribute can be remember or activation
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
