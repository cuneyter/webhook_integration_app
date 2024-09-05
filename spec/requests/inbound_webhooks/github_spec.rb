require 'rails_helper'

RSpec.describe "InboundWebhooks::Github", type: :request do
  describe 'POST #create' do
    let(:payload) { { action: "test_action", data: "test_data" }.to_json }

    before do
      allow_any_instance_of(ActionDispatch::Request).to receive(:body).and_return(StringIO.new(payload))
      allow_any_instance_of(InboundWebhooks::GithubController).to receive(:signing_secret).and_return("secret")
      allow_any_instance_of(InboundWebhooks::GithubController).to receive(:verified_request?).and_return(verification_result)
    end

    context 'with verified request' do
      let(:verification_result) { true }
      let(:valid_headers) { { "X-Hub-Signature-256" => "valid_signature", "Content-Type" => "application/json" } }

      it 'creates a new InboundWebhook record' do
        expect {
          post '/inbound_webhooks/github', params: payload, headers: valid_headers
        }.to change(InboundWebhook, :count).from(0).to(1)

        webhook = InboundWebhook.last
        expect(webhook.event).to eq("test_action")
        expect(webhook.payload).to eq(JSON.parse(payload))
        expect(webhook.controller_name).to eq("InboundWebhooks::GithubController")
        expect(webhook.status).to eq("processing")
      end

      it 'responds with status code 200' do
        post '/inbound_webhooks/github', params: payload, headers: valid_headers
        expect(response).to have_http_status(:ok)
      end

      xit 'enqueues a new InboundWebhooks::Github::HandlerJob' do
        expect {
          post '/inbound_webhooks/github', params: payload, headers: valid_headers
        }.to have_enqueued_job(InboundWebhooks::Github::HandlerJob)
      end
    end

    context 'with unverified request' do
      let(:verification_result) { false }
      let(:invalid_headers) { { "X-Hub-Signature-256" => "invalid_signature", "Content-Type" => "application/json" } }

      it 'does not create a new InboundWebhook record' do
        expect {
          post '/inbound_webhooks/github', params: payload, headers: invalid_headers
        }.not_to change(InboundWebhook, :count)
      end

      it 'responds with status code 400' do
        post '/inbound_webhooks/github', params: payload, headers: invalid_headers
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
