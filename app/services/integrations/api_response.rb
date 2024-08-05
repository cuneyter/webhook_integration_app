# frozen_string_literal: true

# ApiResponse class is a simple data object that represents an HTTP response.
# It provides a success? method that returns true if the response status is in the 200-299 range.
# It also provides a failure? method that returns true if the response status is outside the 200-299 range.

module Integrations
  class ApiResponse
    attr_reader :status, :body, :error_message

    def initialize(status:, body:, error_message: nil)
      @status = status
      @body = body
      @error_message = error_message
    end

    def success?
      (200..299).include?(status)
    end

    def failure?
      !success?
    end
  end
end
