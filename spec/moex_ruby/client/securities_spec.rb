# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MoexRuby::Client::Securities do
  let(:client) { MoexRuby::Client.new }

  describe '#security' do
    let(:response_body) do
      {
        'description' => {
          'columns' => %w[name value],
          'data' => [
            %w[SECID SBER],
            ['NAME', 'Сбербанк']
          ]
        }
      }
    end

    it 'fetches information about a security' do
      stub_request(:get, 'https://iss.moex.com/iss/securities/SBER.json')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.security('SBER')
      expect(result).to be_an(Array)
      expect(result.first[:name]).to eq('SECID')
    end

    it 'passes additional parameters' do
      stub_request(:get, 'https://iss.moex.com/iss/securities/SBER.json?lang=en')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      client.security('SBER', lang: 'en')
      expect(WebMock).to have_requested(:get, 'https://iss.moex.com/iss/securities/SBER.json?lang=en')
    end
  end

  describe '#securities' do
    let(:response_body) do
      {
        'securities' => {
          'columns' => %w[SECID NAME],
          'data' => [
            %w[SBER Сбербанк],
            %w[GAZP Газпром]
          ]
        }
      }
    end

    it 'fetches list of securities' do
      stub_request(:get, 'https://iss.moex.com/iss/securities.json')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.securities
      expect(result).to be_an(Array)
      expect(result.size).to eq(2)
      expect(result.first[:secid]).to eq('SBER')
    end

    it 'accepts query parameters' do
      stub_request(:get, 'https://iss.moex.com/iss/securities.json?is_trading=1&limit=10')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      client.securities(is_trading: 1, limit: 10)
      expect(WebMock).to have_requested(:get, 'https://iss.moex.com/iss/securities.json?is_trading=1&limit=10')
    end
  end

  describe '#search_securities' do
    let(:response_body) do
      {
        'securities' => {
          'columns' => %w[SECID NAME],
          'data' => [%w[SBER Сбербанк]]
        }
      }
    end

    it 'searches securities by query' do
      stub_request(:get, 'https://iss.moex.com/iss/securities.json?q=%D0%A1%D0%B1%D0%B5%D1%80%D0%B1%D0%B0%D0%BD%D0%BA')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.search_securities('Сбербанк')
      expect(result).to be_an(Array)
      expect(result.first[:secid]).to eq('SBER')
    end

    it 'passes additional parameters' do
      stub_request(:get, 'https://iss.moex.com/iss/securities.json?limit=5&q=SBER')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      client.search_securities('SBER', limit: 5)
      expect(WebMock).to have_requested(:get, 'https://iss.moex.com/iss/securities.json?limit=5&q=SBER')
    end
  end

  describe '#indices' do
    it 'fetches indices information' do
      response_body = { 'indices' => { 'columns' => %w[SECID VALUE], 'data' => [%w[IMOEX 3500]] } }
      stub_request(:get, 'https://iss.moex.com/iss/statistics/engines/stock/markets/index/analytics.json')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.indices
      expect(result).to be_an(Array)
    end
  end

  describe '#index' do
    it 'fetches specific index information' do
      response_body = { 'description' => { 'columns' => %w[SECID NAME], 'data' => [%w[IMOEX Индекс]] } }
      stub_request(:get, 'https://iss.moex.com/iss/securities/IMOEX.json')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.index('IMOEX')
      expect(result).to be_an(Array)
    end
  end

  describe '#securities_aggregates' do
    it 'fetches aggregated securities data' do
      response_body = { 'aggregates' => { 'columns' => %w[DATE VALUE], 'data' => [['2024-01-15', 1000]] } }
      stub_request(:get, 'https://iss.moex.com/iss/securities/aggregates.json?date=2024-01-15')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.securities_aggregates(date: '2024-01-15')
      expect(result).to be_an(Array)
    end
  end
end

