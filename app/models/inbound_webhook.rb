class InboundWebhook < ApplicationRecord
  enum :status, %i[pending processing processed failed unhandled]

  validates :event, :status, :payload, :controller_name, presence: true
  validates :inbound_webhook_id, uniqueness: true, allow_nil: true
end
