# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MoexRuby::FaradayConnection do
  let(:faraday_connection) { instance_double(Faraday::Connection) }
  let(:connection) { described_class.new(faraday_connection) }

  describe '#get' do
    let(:response_body) do
      {
        'securities' => {
          'columns' => %w[SECID NAME],
          'data' => [%w[SBER Sberbank]]
        }
      }
    end

    let(:faraday_response) { instance_double(Faraday::Response, body: response_body) }

    it 'makes GET request and parses response' do
      expect(faraday_connection).to receive(:get).with('/iss/securities', {}).and_return(faraday_response)

      result = connection.get('/iss/securities')
      expect(result).to be_an(Array)
      expect(result.first[:secid]).to eq('SBER')
    end

    it 'passes query parameters' do
      expect(faraday_connection).to receive(:get).with('/iss/securities', { date: '2024-01-15' }).and_return(faraday_response)

      connection.get('/iss/securities', date: '2024-01-15')
    end

    it 'handles Faraday errors' do
      error = Faraday::TimeoutError.new('Request timeout')
      expect(faraday_connection).to receive(:get).and_raise(error)

      expect { connection.get('/iss/securities') }.to raise_error(MoexRuby::TimeoutError, 'Request timeout')
    end

    it 'handles empty response' do
      empty_response = instance_double(Faraday::Response, body: nil)
      expect(faraday_connection).to receive(:get).and_return(empty_response)

      result = connection.get('/iss/securities')
      expect(result).to eq([])
    end
  end

  describe 'HANDLED_ERRORS' do
    it 'is frozen to prevent modifications' do
      expect(described_class::HANDLED_ERRORS).to be_frozen
    end

    it 'includes all Faraday network errors' do
      expect(described_class::HANDLED_ERRORS).to include(
        Faraday::TimeoutError,
        Faraday::ConnectionFailed
      )
    end

    it 'includes all Faraday HTTP errors' do
      expect(described_class::HANDLED_ERRORS).to include(
        Faraday::ClientError,
        Faraday::ServerError
      )
    end

    it 'contains exactly 4 error classes' do
      expect(described_class::HANDLED_ERRORS.size).to eq(4)
    end

    context 'when handling different error types' do
      let(:faraday_response) { instance_double(Faraday::Response, body: {}) }

      described_class::HANDLED_ERRORS.each do |error_class|
        it "handles #{error_class.name}" do
          error = error_class.new('Test error')
          expect(faraday_connection).to receive(:get).and_raise(error)
          expect(MoexRuby::ErrorHandler).to receive(:handle).with(error)

          connection.get('/test')
        end
      end
    end
  end
end
