# docs: https://docs.github.com/en/webhooks/webhook-events-and-payloads

module InboundWebhooks
  class GithubController < ApplicationController
    def create
      if verified_request?
        webhook_record = create_webhook_record
        webhook_record.processing!

        # TODO: Add a job to process the webhook
        # InboundWebhooks::Github::HandlerJob.perform_later(webhook_record.id)
        head :ok
      else
        head :bad_request
      end
    end

    private

    def create_webhook_record
      InboundWebhook.create!(
        event: webhook_payload["action"],
        payload: webhook_payload,
        controller_name: self.class.name,
        source_ip: request.remote_ip,
        inbound_webhook_id: webhook_payload["hook_id"]
      )
    end

    def hmac_header
      request.headers["X-Hub-Signature-256"]
    end

    def signing_secret
      Rails.application.credentials.github[:signing_secret]
    end
  end
end
