# frozen_string_literal: true

require 'rails_helper'
require_relative './dummy_http_client'

RSpec.describe DummyHttpClient do
  let(:base_url) { 'https://example.com' }
  let(:response_body_content) { { key: 'value' }.to_json }

  let(:http_response_body) do
    instance_double(HTTP::Response::Body, to_s: response_body_content, empty?: false)
  end

  let(:http_response_status) do
    instance_double(HTTP::Response::Status, code: status, reason: 'OK', success?: status < 400)
  end

  let(:http_response) do
    instance_double(
      HTTP::Response,
      code: status,
      status: http_response_status,
      body: response_body_content,
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  let(:http_client) { instance_double(HTTP::Client) }

  subject(:client) { described_class.new(base_url) }

  before do
    allow(HTTP).to receive(:timeout).and_return(http_client)
    allow(http_client).to receive(:headers).and_return(http_client)
    allow(http_client).to receive(:request).and_return(http_response)
  end

  describe '#execute_request' do
    let(:status) { 200 }

    context 'when the request is successful' do
      it 'returns the response body' do
        response = client.execute_request
        expect(response.body).to eq(JSON.parse(response_body_content))
      end

      it 'returns a successful response' do
        response = client.execute_request
        expect(response.success?).to be true
        expect(response.status.code).to eq(200)
      end
    end

    context 'when the request is unsuccessful' do
      let(:status) { 500 }
      let(:response_body) { 'Internal Server Error' }

      it 'raises a ServerError' do
        response = client.execute_request
        expect(response.error_message).to include('Server error: #[InstanceDouble(HTTP::Response::Status) (anonymous)], {"key":"value"}')
        expect(response.failure?).to be true
        expect(response.status.code).to eq(500)
      end
    end
  end

  xdescribe '#get' do
    let(:response_body) { { key: 'value' }.to_json }
    let(:status) { 200 }

    it 'makes a GET request and returns the response body' do
      response = client.send(:get, path: '/path')
      # expect(http_client).to have_received(:get).with('/path', {})
      expect(response.status).to eq(200)
      expect(response.body).to eq(JSON.parse(response_body))
    end
  end

  xdescribe '#post' do
    let(:status) { 201 }
    let(:post_body) { { data: 'example' } }
    let(:formatted_body) { post_body.to_json }

    before do
      allow(faraday_connection).to receive(:post).and_return(faraday_response)
    end

    it 'makes a POST request and returns the response body' do
      response = client.send(:post, '/path', post_body)
      expect(faraday_connection).to have_received(:post).with('/path', formatted_body)
      expect(response.status).to eq(201)
      expect(response.body).to eq(JSON.parse(response_body))
    end
  end

  xdescribe '#put' do
    let(:status) { 204 }
    let(:put_body) { { data: 'example' } }
    let(:formatted_body) { put_body.to_json }

    before do
      allow(faraday_connection).to receive(:put).and_return(faraday_response)
    end

    it 'makes a PUT request and returns the response body' do
      response = client.send(:put, '/path', put_body)
      expect(faraday_connection).to have_received(:put).with('/path', formatted_body)
      expect(response.status).to eq(204)
      expect(response.body).to eq(JSON.parse(response_body))
    end
  end

  xdescribe '#delete' do
    let(:status) { 204 }

    before do
      allow(faraday_connection).to receive(:delete).and_return(faraday_response)
    end

    it 'makes a DELETE request and returns the response body' do
      response = client.send(:delete, '/path')
      expect(faraday_connection).to have_received(:delete).with('/path', {})
      expect(response.status).to eq(204)
      expect(response.body).to eq(JSON.parse(response_body))
    end
  end

  describe '#format_body' do
    let(:status) { 200 }

    context 'when content type is application/json' do
      it 'formats body as JSON' do
        body = { key: 'value' }
        expect(client.send(:format_body, body)).to eq(body.to_json)
      end
    end

    context 'when content type is not application/json' do
      it 'returns body as is' do
        allow(client).to receive(:content_type).and_return('text/plain')
        body = 'plain text'
        expect(client.send(:format_body, body)).to eq(body)
      end
    end
  end
end
