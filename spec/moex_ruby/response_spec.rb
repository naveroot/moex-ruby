# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MoexRuby::Response do
  describe '.parse' do
    it 'returns empty array for nil body' do
      expect(described_class.parse(nil)).to eq([])
    end

    it 'returns empty array for empty body' do
      expect(described_class.parse({})).to eq([])
    end

    it 'transforms ISS format to array of hashes' do
      body = {
        'history' => {
          'columns' => %w[SECID TRADEDATE CLOSE],
          'data' => [
            ['SBER', '2024-01-15', 285.50],
            ['GAZP', '2024-01-15', 165.20]
          ]
        }
      }

      result = described_class.parse(body)
      expect(result).to be_an(Array)
      expect(result.size).to eq(2)
      expect(result.first).to eq({ secid: 'SBER', tradedate: '2024-01-15', close: 285.50 })
      expect(result.last).to eq({ secid: 'GAZP', tradedate: '2024-01-15', close: 165.20 })
    end

    it 'handles multiple blocks in response' do
      body = {
        'securities' => {
          'columns' => %w[SECID NAME],
          'data' => [%w[SBER Sberbank]]
        },
        'marketdata' => {
          'columns' => %w[SECID LAST],
          'data' => [['SBER', 285.50]]
        }
      }

      result = described_class.parse(body)
      expect(result).to be_a(Hash)
      expect(result[:securities]).to eq([{ secid: 'SBER', name: 'Sberbank' }])
      expect(result[:marketdata]).to eq([{ secid: 'SBER', last: 285.50 }])
    end

    it 'handles null values' do
      body = {
        'history' => {
          'columns' => %w[SECID CLOSE],
          'data' => [['SBER', nil]]
        }
      }

      result = described_class.parse(body)
      expect(result.first[:close]).to be_nil
    end
  end
end
