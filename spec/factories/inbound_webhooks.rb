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
FactoryBot.define do
  factory :inbound_webhook do
    event { "test_event" }
    status { "pending" }
    payload { { key: "value" } }
    controller_name { "TestController" }
    inbound_webhook_id { "12345" }
  end
end
