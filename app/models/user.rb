class User < ApplicationRecord
  attr_accessor :remember_token
  before_save {self.email = email.downcase}
  validates :name, presence:true, length: {maximum:50}
   VALID_EMAIL_REGEX =  /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence:true, length: {maximum:255},
             format: {with:VALID_EMAIL_REGEX},
             uniqueness:{case_sensitive:false}
  has_secure_password
  validates :password, presence:true, length: {minimum:6}

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
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token) # this 'remember_token' is not instance variable
  end

  # Remove login info
  def forget
    update_attribute(:remember_digest, nil)
  end
end
