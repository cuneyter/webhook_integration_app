module InboundWebhooks
  module Github
    class PullRequestClosedEventService
      attr_reader :webhook

      def initialize(webhook)
        @webhook = webhook
      end

      def process
        # Extract relevant information from the payload
        payload = webhook.payload
        pull_request = payload["pull_request"]
        repository = payload["repository"]

        # Send email notification
        GithubNotificationMailer.pull_request_closed_notification(
          email: "cuneytergun@live.com",
          pr_title: pull_request["title"],
          pr_number: pull_request["number"],
          pr_url: pull_request["html_url"],
          repository_name: repository["full_name"],
          repository_url: repository["html_url"],
          merged: pull_request["merged"],
          closed_by: payload["sender"]["login"]
        ).deliver_later
      end
    end
  end
end
