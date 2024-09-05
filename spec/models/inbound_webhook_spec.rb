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
#  status             :integer          default("pending"), not null
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
require "rails_helper"

RSpec.describe InboundWebhook, type: :model do
  subject { build :inbound_webhook }

  it { is_expected.to be_valid }

  it "is invalid without an event" do
    subject.event = nil
    expect(subject).not_to be_valid
  end

  it "is invalid without a status" do
    subject.status = nil
    expect(subject).not_to be_valid
  end

  it "is invalid without a payload" do
    subject.payload = nil
    expect(subject).not_to be_valid
  end

  it "is invalid without a controller_name" do
    subject.controller_name = nil
    expect(subject).not_to be_valid
  end

  it "is invalid with a duplicate inbound_webhook_id" do
    create(:inbound_webhook, inbound_webhook_id: subject.inbound_webhook_id)
    expect(subject).not_to be_valid
  end

  it "is valid with a nil inbound_webhook_id" do
    subject.inbound_webhook_id = nil
    expect(subject).to be_valid
  end
end
