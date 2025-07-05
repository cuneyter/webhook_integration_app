require 'rails_helper'
include ActiveJob::TestHelper

RSpec.describe "Github Webhooks", type: :feature do
  let(:payload) { { action: "test_action", data: "test_data" }.to_json }

  before do
    allow_any_instance_of(ActionDispatch::Request).to receive(:body).and_return(StringIO.new(payload))
    allow_any_instance_of(InboundWebhooks::GithubController).to receive(:signing_secret).and_return("secret")
    allow_any_instance_of(InboundWebhooks::GithubController).to receive(:verified_request?).and_return(verification_result)
  end

  context 'with an valid signature' do
    let(:verification_result) { true }
    let(:valid_headers) { { "X-Hub-Signature-256" => "valid_signature", "Content-Type" => "application/json", "Host" => "localhost" } }

    scenario 'receives and processes a webhook' do
      expect {
        page.driver.post '/inbound_webhooks/github', payload, valid_headers
      }.to change(InboundWebhook, :count).from(0).to(1)

      webhook = InboundWebhook.last
      expect(webhook.event).to eq("test_action")
      expect(webhook.payload).to eq(JSON.parse(payload))
      expect(webhook.controller_name).to eq("InboundWebhooks::GithubController")
      expect(webhook.status).to eq("processing")

      expect(page.status_code).to eq(200)

      # TODO: Uncomment this line once the job is enqueued
      # expect(InboundWebhooks::Github::HandlerJob).to have_been_enqueued.with(webhook.id)
    end
  end

  context "with an invalid signature" do
    let(:verification_result) { false }
    let(:invalid_headers) { { "X-Hub-Signature-256" => "invalid_signature", "Content-Type" => "application/json", "Host" => "localhost" } }

    scenario 'rejects webhook' do
      page.driver.post '/inbound_webhooks/github', payload, invalid_headers

      expect(page.status_code).to eq(400)
    end

    scenario 'does not create a new InboundWebhook record' do
      expect {
        page.driver.post '/inbound_webhooks/github', payload, invalid_headers
      }.not_to change(InboundWebhook, :count)
    end
  end
end
