# frozen_string_literal: true

# require_relative '../../../app/services/integrations/api_response'
# require_relative '../../../app/services/integrations/http_client_errors'
require_relative '../../../app/services/integrations/faraday_client'

class DummyHttpClient
  include Integrations::FaradayClient

  def initialize(base_url)
    @base_url = base_url
  end

  def url
    @base_url
  end

  def do_request
    get('/path')
  end

  def auth
    'Bearer token'
  end
end
