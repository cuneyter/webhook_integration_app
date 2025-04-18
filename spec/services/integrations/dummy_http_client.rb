# frozen_string_literal: true

require_relative '../../../app/services/integrations/http_client'

class DummyHttpClient
  include Integrations::HttpClient

  def initialize(base_url)
    @base_url = base_url
  end

  def url
    @base_url
  end

  def do_request
    get(path: '/path')
  end

  def auth
    'Bearer token'
  end
end
