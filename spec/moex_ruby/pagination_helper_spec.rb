# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MoexRuby::PaginationHelper do
  describe '.normalize_data' do
    it 'returns empty array for nil' do
      expect(described_class.normalize_data(nil)).to eq([])
    end

    it 'returns empty array for empty array' do
      expect(described_class.normalize_data([])).to eq([])
    end

    it 'returns empty array for empty hash' do
      expect(described_class.normalize_data({})).to eq([])
    end

    it 'returns array as is' do
      data = [{ id: 1 }, { id: 2 }]
      expect(described_class.normalize_data(data)).to eq(data)
    end

    it 'returns first value from hash' do
      data = { securities: [{ id: 1 }, { id: 2 }], marketdata: [{ last: 100 }] }
      expect(described_class.normalize_data(data)).to eq([{ id: 1 }, { id: 2 }])
    end

    it 'returns empty array for hash with nil value' do
      data = { securities: nil }
      expect(described_class.normalize_data(data)).to eq([])
    end

    it 'returns empty array for unsupported types' do
      expect(described_class.normalize_data('string')).to eq([])
      expect(described_class.normalize_data(123)).to eq([])
    end
  end

  describe '.extract_size' do
    it 'returns 0 for nil' do
      expect(described_class.extract_size(nil)).to eq(0)
    end

    it 'returns 0 for empty array' do
      expect(described_class.extract_size([])).to eq(0)
    end

    it 'returns 0 for empty hash' do
      expect(described_class.extract_size({})).to eq(0)
    end

    it 'returns size for array' do
      data = [{ secid: 'SBER' }, { secid: 'GAZP' }]
      expect(described_class.extract_size(data)).to eq(2)
    end

    it 'returns size of first value for hash' do
      data = { securities: [{ secid: 'SBER' }, { secid: 'GAZP' }] }
      expect(described_class.extract_size(data)).to eq(2)
    end

    it 'returns 0 for hash with empty array' do
      data = { securities: [] }
      expect(described_class.extract_size(data)).to eq(0)
    end

    it 'returns 0 for hash with nil value' do
      data = { securities: nil }
      expect(described_class.extract_size(data)).to eq(0)
    end

    it 'returns 0 for unsupported types' do
      expect(described_class.extract_size('string')).to eq(0)
      expect(described_class.extract_size(123)).to eq(0)
    end
  end
end

