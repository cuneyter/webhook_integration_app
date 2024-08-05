# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../app/services/integrations/api_response'

RSpec.describe Integrations::ApiResponse do
  subject(:api_response) { described_class.new(status: status, body: body, error_message: error_message) }

  let(:status) { 200 }
  let(:body) { { key: 'value' } }
  let(:error_message) { nil }

  describe '#initialize' do
    it 'initializes with status, body, and error_message' do
      expect(api_response.status).to eq(status)
      expect(api_response.body).to eq(body)
      expect(api_response.error_message).to eq(error_message)
    end
  end

  describe '#success?' do
    context 'when status is within 200-299 range' do
      let(:status) { 200 }

      it 'returns true' do
        expect(api_response.success?).to be true
      end
    end

    context 'when status is outside 200-299 range' do
      let(:status) { 404 }

      it 'returns false' do
        expect(api_response.success?).to be false
      end
    end
  end

  describe '#failure?' do
    context 'when status is within 200-299 range' do
      let(:status) { 200 }

      it 'returns false' do
        expect(api_response.failure?).to be false
      end
    end

    context 'when status is outside 200-299 range' do
      let(:status) { 404 }

      it 'returns true' do
        expect(api_response.failure?).to be true
      end
    end
  end
end
