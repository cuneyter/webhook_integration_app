module InboundWebhooks
  module Github
    class HandlerJob < ApplicationJob
      queue_as :default

      def perform(webhook_id)
        webhook = InboundWebhook.find(webhook_id)

        begin
          # Process the webhook based on its event type
          case webhook.event
          when "push"
            InboundWebhooks::Github::PushEventService.new(webhook).process
          when "pull_request.closed"
            InboundWebhooks::Github::PullRequestClosedEventService.new(webhook).process
          else
            webhook.status_unhandled!
            Rails.logger.info("Unhandled GitHub webhook event: #{webhook.event}")
          end

          webhook.update!(processed_at: Time.current, status: "processed")
        rescue => e
          webhook.update!(
            status: "failed",
            error_message: "#{e.class}: #{e.message}\n#{e.backtrace.join("\n")}"
          )
          Rails.logger.error("Error processing GitHub webhook: #{e.message}")
          raise
        end
      end
    end
  end
end
