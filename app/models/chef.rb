class Chef < ApplicationRecord
  validates :chefname, presence: true, length: { maximum: 30 }
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
                    
  before_save { self.email = email.downcase }
  has_many :recipes
  has_secure_password
  validates :password, presence: true, length: { minimum: 5 }
end