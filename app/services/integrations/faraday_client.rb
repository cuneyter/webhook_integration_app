# frozen_string_literal: true

# HttpClient module is a mixin that provides a common interface for making HTTP requests.
# It is designed to be included in classes that need to make HTTP requests.
module Integrations
  module FaradayClient
    include HttpClientErrors

    # Executes the HTTP request and returns the response.
    # @return [Object] the response object
    def execute_request
      @execute_request ||= response
    end

    protected

    # Returns the response object, memorising the result.
    # @return [Object] the response object
    def response
      @response ||= do_request
    end

    # Abstract method to perform the actual HTTP request.
    # Subclasses must implement this method.
    # @raise [NotImplementedError] if the method is not implemented in a subclass
    def do_request
      raise NotImplementedError, "Subclass must implement #do_request"
    end

    # Abstract method to return the URL for the HTTP request.
    # Subclasses must implement this method.
    # @raise [NotImplementedError] if the method is not implemented in a subclass
    def url
      raise NotImplementedError, "Subclass must implement #url"
    end

    # Abstract method to return the authorization header for the HTTP request.
    # Subclasses must implement this method.
    # @raise [NotImplementedError] if the method is not implemented in a subclass
    def auth
      raise NotImplementedError, "Subclass must implement #auth"
    end

    # Returns additional headers for the HTTP request.
    # @return [Hash] a hash of additional headers
    def additional_headers
      {}
    end

    # Returns the content type for the HTTP request.
    # @return [String] the content type
    def content_type
      "application/json"
    end

    # Returns the request type for the HTTP request.
    # @return [Symbol] the request type
    def request_type
      :url_encoded
    end

    # Returns the timeout for the HTTP request.
    # @return [Integer] the timeout in seconds
    def timeout
      30
    end

    # Performs a GET request.
    # @param [String] path the path for the GET request
    # @param [Hash] params the parameters for the GET request
    # @return [Object] the response object
    def get(path, params = {})
      request(:get, path, params)
    end

    # Performs a POST request.
    # @param [String] path the path for the POST request
    # @param [Hash] body the body for the POST request
    # @return [Object] the response object
    def post(path, body = {})
      request(:post, path, body)
    end

    # Performs a PUT request.
    # @param [String] path the path for the PUT request
    # @param [Hash] body the body for the PUT request
    # @return [Object] the response object
    def put(path, body = {})
      request(:put, path, body)
    end

    # Performs a DELETE request.
    # @param [String] path the path for the DELETE request
    # @param [Hash] params the parameters for the DELETE request
    # @return [Object] the response object
    def delete(path, params = {})
      request(:delete, path, params)
    end

    private

    # Performs the HTTP request based on the given method, path, and body or parameters.
    # @param [Symbol] method the HTTP method (:get, :post, :put, :delete)
    # @param [String] path the path for the HTTP request
    # @param [Hash] body_or_params the body or parameters for the HTTP request
    # @return [Object] the response object
    def request(method, path, body_or_params = {})
      formatted_body_or_params = format_body_or_params(method, body_or_params)
      handle_request { connection.send(method, path, formatted_body_or_params) }
    end

    # Formats the request body or parameters based on the content type and request method.
    # @param [Symbol] method the HTTP method (:get, :post, :put, :delete)
    # @param [Hash] body_or_params the request body or parameters
    # @return [String, Hash] the formatted request body or parameters
    def format_body_or_params(method, body_or_params)
      if %i[post put].include?(method) && json_content?
        body_or_params.to_json
      else
        body_or_params
      end
    end

    # Returns the Faraday connection object, memorising the result.
    # @return [Faraday::Connection] the Faraday connection object
    def connection
      @connection ||= Faraday.new(url: url) do |faraday|
        faraday.request request_type
        faraday.headers["Authorization"] = auth if auth
        faraday.headers["Content-Type"] = content_type
        faraday.headers.merge!(additional_headers)
        faraday.options.timeout = timeout
        faraday.response(:logger)
        faraday.adapter Faraday.default_adapter
      end
    end

    # Handles the HTTP request and processes the response.
    # @yield the block that performs the HTTP request
    # @return [Object] the processed response object
    def handle_request
      response = yield
      handle_errors(response)
      build_success_response(response)
    rescue StandardError => error
      build_error_response(error)
    end

    # Handles errors based on the HTTP response status.
    # @param [Faraday::Response] response the HTTP response
    # @return [Faraday::Response] the original response
    def handle_errors(response)
      case response.status
      when 502, 504
        raise TimeoutError.new(response)
      when 500, 503
        raise ServerError.new(response)
      when 400, 401, 404, 422, 429
        raise ClientError.new(response)
      else
        response
      end
    end

    # Builds the success response object from the HTTP response.
    # @param [Faraday::Response] response the HTTP response
    # @return [ApiResponse] the API response object
    def build_success_response(response)
      body = parse_response(response)
      ApiResponse.new(status: response.status, body: body) if success?(response)
    end

    # Builds the error response object from the error.
    # @param [StandardError] error the error object
    # @return [ApiResponse] the API response object
    def build_error_response(error)
      ApiResponse.new(status: error.response.status, body: error.response.body, error_message: error.message)
    end

    # Checks if the HTTP response is successful.
    # @param [Faraday::Response] response the HTTP response
    # @return [Boolean] true if the response status is in the 200-299 range, false otherwise
    def success?(response)
      (200..299).include?(response.status)
    end

    # Parses the HTTP response body.
    # @param [Faraday::Response] response the HTTP response
    # @return [Hash, String] the parsed response body
    def parse_response(response)
      return {} if response.body.nil?

      json_content? ? JSON.parse(response.body) : response.body
    rescue JSON::ParserError
      {}
    end

    # Formats the request body based on the content type.
    # @param [Hash] body the request body
    # @return [String, Hash] the formatted request body
    def format_body(body)
      json_content? ? body.to_json : body
    end

    # Checks if the content type is JSON.
    # @return [Boolean] true if the content type is "application/json", false otherwise
    def json_content?
      content_type == "application/json"
    end
  end
end
