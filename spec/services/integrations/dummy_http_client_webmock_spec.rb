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
        expect(response.success?).to be false
        expect(response.status).to eq(500)
        expect(response.error_message).to eq('Server error: 500 Internal Server Error, Internal Server Error')
      end
    end
  end

  describe '#get' do
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

    it 'makes a GET request and returns the response body' do
      response = client.send(:get, path: '/path')
      expect(response.status).to eq(200)
      expect(response.body).to eq(JSON.parse(response_body))
    end
  end

  describe '#post' do
    let(:status) { 201 }
    let(:post_body) { { data: 'example' } }
    let(:response_body) { post_body.to_json }

    before do
      stub_request(:post, "#{base_url}/path")
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

    it 'makes a POST request and returns the response body' do
      response = client.send(:post, path: '/path', body: post_body)
      expect(WebMock)
        .to have_requested(:post, "#{base_url}/path")
              .with(body: post_body.to_json)
      expect(response.status).to eq(201)
      expect(response.body).to eq({ "data"=>"example" })
    end
  end

  describe '#put' do
    let(:status) { 201 }
    let(:put_body) { { data: 'example' } }
    let(:response_body) { put_body.to_json }

    before do
      stub_request(:put, "#{base_url}/path")
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

    it 'makes a PUT request and returns the response body' do
      response = client.send(:put, path: '/path', body: put_body)
      expect(response.status).to eq(201)
      expect(response.body).to eq({ "data"=>"example" })
    end
  end

  describe '#delete' do
    let(:status) { 204 }

    before do
      stub_request(:delete, "#{base_url}/path")
        .with(
          headers: {
            'Authorization' => 'Bearer token',
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: status,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'makes a DELETE request and returns the response body' do
      response = client.send(:delete, path: '/path')
      expect(response.status).to eq(204)
      expect(response.body).to eq({})
    end
  end

  describe '#format_body' do
    context 'when content type is application/json' do
      let(:body) { { key: 'value' } }
      let(:formatted_body) { body.to_json }

      it 'returns the body as a JSON string' do
        expect(client.send(:format_body, body)).to eq(formatted_body)
      end
    end
  end
end
