# frozen_string_literal: true

# HttpClient module is a mixin that provides a common interface for making HTTP requests.
# It is designed to be included in classes that need to make HTTP requests.
module Integrations
  module HttpClient
    include HttpErrorHandling

    # Executes the HTTP request and returns the response.
    # @return [ApiResponse] the response object
    def execute_request
      @execute_request ||= response
    end

    protected

    # Returns the response object, memorising the result.
    # @return [ApiResponse] the response object
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

    # Returns the timeout for the HTTP request.
    # @return [Integer] the timeout in seconds
    def timeout
      30
    end

    # Performs a GET request.
    # @param [String] path the path for the GET request
    # @param [Hash] params the parameters for the GET request
    # @return [ApiResponse] the response object
    def get(path:, params: {})
      request(method: :get, path: path, options: { params: params })
    end

    # Performs a POST request.
    # @param [String] path the path for the POST request
    # @param [Hash] body the body for the POST request
    # @return [ApiResponse] the response object
    def post(path:, body: {})
      request(method: :post, path: path, options: { body: format_body(body) })
    end

    # Performs a PUT request.
    # @param [String] path the path for the PUT request
    # @param [Hash] body the body for the PUT request
    # @return [ApiResponse] the response object
    def put(path:, body: {})
      request(method: :put, path: path, options: { body: format_body(body) })
    end

    # Performs a DELETE request.
    # @param [String] path the path for the DELETE request
    # @param [Hash] params the parameters for the DELETE request
    # @return [ApiResponse] the response object
    def delete(path:, params: {})
      request(method: :delete, path: path, options: { params: params })
    end

    private

    # Performs the HTTP request based on the given method, path, and options.
    # @param [Symbol] method the HTTP method (:get, :post, :put, :delete)
    # @param [String] path the path for the HTTP request
    # @param [Hash] options the options for the HTTP request (e.g., params, body)
    # @return [ApiResponse] the response object
    def request(method:, path:, options: {})
      full_url = build_url(path)
      handle_request { http_client.request(method, full_url, options) }
    end

    # Builds the full URL for the request.
    # @param [String] path the path for the HTTP request
    # @return [String] the full URL
    def build_url(path)
      URI.join(url, path).to_s
    end

    # Returns the HTTP client with configured headers and timeouts.
    # @return [HTTP::Client] the HTTP client
    def http_client
      @http_client ||= begin
                         client = HTTP.timeout(connect: timeout, read: timeout)
                         client = client.headers(default_headers)
                         client
                       end
    end

    # Returns the default headers for the HTTP request.
    # @return [Hash] a hash of default headers
    def default_headers
      headers = { "Content-Type" => content_type }
      headers["Authorization"] = auth if auth
      headers.merge(additional_headers)
    end

    # Handles the HTTP request and processes the response.
    # @yield the block that performs the HTTP request
    # @return [ApiResponse] the response object
    def handle_request
      response = yield
      handle_errors(response)
      build_success_response(response)
    rescue StandardError => error
      build_error_response(error)
    end

    # Handles errors based on the HTTP response status.
    # @param [HTTP::Response] response the HTTP response
    # @return [HTTP::Response] the original response
    def handle_errors(response)
      case response.code
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
    # @param [HTTP::Response] response the HTTP response
    # @return [ApiResponse] the API response object
    def build_success_response(response)
      body = parse_response(response)
      ApiResponse.new(status: response.status, body: body) if response.status.success?
    end

    # Builds the error response object from the error.
    # @param [StandardError] error the error object
    # @return [ApiResponse] the API response object
    def build_error_response(error)
      ApiResponse.new(
        status: error.response&.status || HTTP::Response::Status.new(500),
        body: error.response&.body || {},
        error_message: error.message
      )
    end

    # Parses the HTTP response body.
    # @param [HTTP::Response] response the HTTP response
    # @return [Hash, String, HTTP::Response::Body] the parsed response body
    def parse_response(response)
      body = response.body.to_s
      return {} if body.empty?

      if response.headers["Content-Type"]&.include?("application/json")
        JSON.parse(body)
      else
        body
      end
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
