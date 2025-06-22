# == Schema Information
#
# Table name: sessions
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  ip_address :string
#  user_agent :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_sessions_on_user_id  (user_id)
#

class Session < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validates :ip_address, presence: true, if: :ip_address_required?
  validates :user_agent, presence: true, if: :user_agent_required?

  private

  def ip_address_required?
    false
  end

  def user_agent_required?
    false
  end
end
