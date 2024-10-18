# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../app/services/integrations/http_error_handing'

RSpec.describe Integrations::HttpErrorHanding do
  let(:response) { instance_double(Faraday::Response, status: status, body: body) }
  let(:status) { 500 }
  let(:body) { 'Internal Server Error' }

  describe Integrations::HttpErrorHanding::ServerError do
    subject(:error) { described_class.new(response) }

    it 'initializes with a response' do
      expect(error.response).to eq(response)
    end

    it 'returns the correct error message' do
      expect(error.message).to eq("Server error: #{status}, #{body}")
    end
  end

  describe Integrations::HttpErrorHanding::TimeoutError do
    subject(:error) { described_class.new(response) }

    let(:status) { 504 }
    let(:body) { 'Gateway Timeout' }

    it 'initializes with a response' do
      expect(error.response).to eq(response)
    end

    it 'returns the correct error message' do
      expect(error.message).to eq("Timeout error: #{status}, #{body}")
    end
  end

  describe Integrations::HttpErrorHanding::ClientError do
    subject(:error) { described_class.new(response) }

    let(:status) { 400 }
    let(:body) { 'Bad Request' }

    it 'initializes with a response' do
      expect(error.response).to eq(response)
    end

    it 'returns the correct error message' do
      expect(error.message).to eq("Client error: #{status}, #{body}")
    end
  end
end
