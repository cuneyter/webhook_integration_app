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
