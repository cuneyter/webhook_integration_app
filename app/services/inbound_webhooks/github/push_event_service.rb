module InboundWebhooks
  module Github
    class PushEventService
      attr_reader :webhook

      def initialize(webhook)
        @webhook = webhook
      end

      def process
        # Extract relevant information from the payload
        payload = webhook.payload
        repository = payload["repository"]
        pusher = payload["pusher"]

        # Send email notification
        GithubNotificationMailer.push_event_notification(
          email: pusher["email"],
          pusher_name: pusher["name"],
          repository_name: repository["full_name"],
          repository_url: repository["html_url"],
          ref: payload["ref"],
          compare_url: payload["compare"],
          deleted: payload["deleted"]
        ).deliver_later
      end
    end
  end
end
