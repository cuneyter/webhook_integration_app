# == Schema Information
#
# Table name: inbound_webhooks
#
#  id                 :bigint           not null, primary key
#  controller_name    :string           not null
#  error_message      :text
#  event              :string           not null
#  payload            :jsonb            not null
#  processed_at       :datetime
#  source_ip          :string
#  status             :string           default("pending"), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  inbound_webhook_id :string
#
# Indexes
#
#  index_inbound_webhooks_on_event               (event)
#  index_inbound_webhooks_on_inbound_webhook_id  (inbound_webhook_id) UNIQUE
#  index_inbound_webhooks_on_status              (status)
#
class InboundWebhook < ApplicationRecord
  enum status: {
    pending: "pending",
    processing: "processing",
    processed: "processed",
    failed: "failed",
    unhandled: "unhandled"
  }, _default: "pending"

  validates :event, :status, :payload, :controller_name, presence: true
  validates :inbound_webhook_id, uniqueness: true, allow_nil: true
end
