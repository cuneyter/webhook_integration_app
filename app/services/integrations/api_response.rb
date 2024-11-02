# frozen_string_literal: true

# \# ApiResponse class is a simple data object that represents an HTTP response.
# \# It provides a \#success? method that returns true if the response status is in the 200-299 range.
# \# It also provides a \#failure? method that returns true if the response status is outside the 200-299 range.

module Integrations
  class ApiResponse
    # @return [HTTP::Response::Status] the HTTP status of the response
    attr_reader :status

    # @return [Hash, HTTP::Response::Body] the body of the HTTP response
    attr_reader :body

    # @return [String, nil] the error message, if any
    attr_reader :error_message

    # Initializes a new ApiResponse object.
    # @param status [HTTP::Response::Status] the HTTP status of the response
    # @param body [Hash, HTTP::Response::Body] the body of the HTTP response
    # @param error_message [String, nil] the error message, if any
    def initialize(status:, body:, error_message: nil)
      @status = status
      @body = body
      @error_message = error_message
    end

    # Checks if the response is successful
    #  status is an instance of HTTP::Response::Status
    # @return [Boolean] true if the response is successful, false otherwise
    def success?
      status.success?
    end

    # Checks if the response is a failure (status code outside the 200-299 range).
    # @return [Boolean] true if the response is a failure, false otherwise
    def failure?
      !success?
    end
  end
end
