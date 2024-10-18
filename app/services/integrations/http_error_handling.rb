# frozen_string_literal: true

# This module is used to handle errors that are raised by the HttpClient

module Integrations
  module HttpErrorHandling
    class ServerError < RuntimeError
      attr_reader :response

      def initialize(response)
        @response = response
        super("Server error: #{response.status}, #{response.body}")
      end
    end

    class TimeoutError < RuntimeError
      attr_reader :response

      def initialize(response)
        @response = response
        super("Timeout error: #{response.status}, #{response.body}")
      end
    end

    class ClientError < RuntimeError
      attr_reader :response

      def initialize(response)
        @response = response
        super("Client error: #{response.status}, #{response.body}")
      end
    end
  end
end
