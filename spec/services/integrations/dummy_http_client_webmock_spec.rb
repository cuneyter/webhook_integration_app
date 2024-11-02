require 'rails_helper'
require 'webmock/rspec'
require_relative './dummy_http_client'

RSpec.describe DummyHttpClient do
  let(:base_url) { 'https://example.com' }
  let(:response_body) { { key: 'value' }.to_json }
  let(:status) { 200 }

  subject(:client) { described_class.new(base_url) }

  describe '#execute_request' do
    before do
      stub_request(:get, "#{base_url}/path")
        .with(
          headers: {
            'Authorization' => 'Bearer token',
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: status,
          body: response_body,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    context 'when the request is successful' do
      it 'returns the response body' do
        response = client.execute_request
        expect(response.body).to eq(JSON.parse(response_body))
      end

      it 'returns a successful response' do
        response = client.execute_request
        expect(response.success?).to be true
        expect(response.status).to eq(200)
      end
    end

    context 'when the request is unsuccessful' do
      let(:status) { 500 }
      let(:error_body) { 'Internal Server Error' }

      before do
        stub_request(:get, "#{base_url}/path")
          .with(
            headers: {
              'Authorization' => 'Bearer token',
              'Content-Type' => 'application/json'
            }
          )
          .to_return(
            status: status,
            body: error_body,
            headers: { 'Content-Type' => 'text/plain' }
          )
      end

      it 'raises a ServerError' do
        response = client.execute_request
        expect(response.error_message).to eq('Server error: 500 Internal Server Error, Internal Server Error')
      end
    end
  end
end
