class ApplicationJob < ActiveJob::Base
  # Enable transaction-safe job enqueueing for Solid Queue
  self.enqueue_after_transaction_commit = true

  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  # Add error reporting for better observability
  rescue_from(Exception) do |exception|
    Rails.logger.error "Job failed: #{exception.message}\n#{exception.backtrace.join("\n")}"
    Rails.error.report(exception)
    raise exception
  end
end
