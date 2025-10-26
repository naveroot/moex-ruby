# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MoexRuby::ErrorHandler do
  describe '.handle' do
    context 'with TimeoutError' do
      it 'raises MoexRuby::TimeoutError' do
        faraday_error = Faraday::TimeoutError.new('timeout')

        expect { described_class.handle(faraday_error) }
          .to raise_error(MoexRuby::TimeoutError, 'timeout')
      end
    end

    context 'with ConnectionFailed' do
      it 'raises MoexRuby::ConnectionError' do
        faraday_error = Faraday::ConnectionFailed.new('connection failed')

        expect { described_class.handle(faraday_error) }
          .to raise_error(MoexRuby::ConnectionError, 'connection failed')
      end
    end

    context 'with ClientError' do
      it 'raises MoexRuby::ClientError with status and response' do
        env = double('env', status: 404)
        response_hash = { status: 404, body: 'Not Found' }
        faraday_error = Faraday::ResourceNotFound.new(nil, { status: 404 })
        allow(faraday_error).to receive(:response).and_return(response_hash)

        expect { described_class.handle(faraday_error) }
          .to raise_error(MoexRuby::ClientError) do |error|
            expect(error.status).to eq(404)
            expect(error.response).to eq(response_hash)
          end
      end
    end

    context 'with ServerError' do
      it 'raises MoexRuby::ServerError with status and response' do
        response_hash = { status: 500, body: 'Internal Server Error' }
        faraday_error = Faraday::ServerError.new(nil, { status: 500 })
        allow(faraday_error).to receive(:response).and_return(response_hash)

        expect { described_class.handle(faraday_error) }
          .to raise_error(MoexRuby::ServerError) do |error|
            expect(error.status).to eq(500)
            expect(error.response).to eq(response_hash)
          end
      end
    end
  end
end

