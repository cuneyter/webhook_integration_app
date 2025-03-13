class GithubNotificationMailer < ApplicationMailer
  default from: "notifications@example.com"

  def push_event_notification(email:, pusher_name:, repository_name:, repository_url:, ref:, compare_url:, deleted:)
    @pusher_name = pusher_name
    @repository_name = repository_name
    @repository_url = repository_url
    @ref = ref
    @branch_name = ref.gsub("refs/heads/", "")
    @compare_url = compare_url
    @deleted = deleted

    mail(
      to: "cuneytergun@gmail.com",
      subject: "GitHub Push: #{pusher_name} #{deleted ? 'deleted' : 'pushed to'} #{@branch_name} in #{repository_name}"
    )
  end

  def pull_request_closed_notification(email:, pr_title:, pr_number:, pr_url:, repository_name:, repository_url:, merged:, closed_by:)
    @pr_title = pr_title
    @pr_number = pr_number
    @pr_url = pr_url
    @repository_name = repository_name
    @repository_url = repository_url
    @merged = merged
    @closed_by = closed_by
    @action = merged ? "merged" : "closed"

    mail(
      to: email,
      subject: "GitHub Pull Request #{@action}: #{pr_title} (##{pr_number}) in #{repository_name}"
    )
  end
end
