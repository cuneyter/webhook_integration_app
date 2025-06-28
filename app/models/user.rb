# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email_address   :string           not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email_address  (email_address) UNIQUE
#

class User < ApplicationRecord
  has_secure_password
  has_many :sessions, inverse_of: :user, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # Use a safer regex that avoids catastrophic backtracking
  EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\.[^@\s\.]+\z/

  validates :email_address, presence: true, uniqueness: { case_sensitive: false }, format: { with: EMAIL_REGEX }

  validates :password, length: { minimum: 8, maximum: 72 }, allow_blank: true
end
