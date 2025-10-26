# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MoexRuby do
  describe 'Error classes' do
    it 'defines base Error class' do
      expect(MoexRuby::Error).to be < StandardError
    end

    it 'defines NetworkError' do
      expect(MoexRuby::NetworkError).to be < MoexRuby::Error
    end

    it 'defines ConnectionError' do
      expect(MoexRuby::ConnectionError).to be < MoexRuby::NetworkError
    end

    it 'defines TimeoutError' do
      expect(MoexRuby::TimeoutError).to be < MoexRuby::NetworkError
    end

    it 'defines HttpError with status and response' do
      error = MoexRuby::HttpError.new('test', status: 400, response: { body: 'bad' })
      expect(error.status).to eq(400)
      expect(error.response).to eq({ body: 'bad' })
    end

    it 'defines ClientError' do
      expect(MoexRuby::ClientError).to be < MoexRuby::HttpError
    end

    it 'defines ServerError' do
      expect(MoexRuby::ServerError).to be < MoexRuby::HttpError
    end

    it 'defines ParseError' do
      expect(MoexRuby::ParseError).to be < MoexRuby::Error
    end
  end
end
