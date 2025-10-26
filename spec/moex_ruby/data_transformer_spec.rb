# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MoexRuby::DataTransformer do
  describe '#transform' do
    let(:columns) { %w[SECID BOARDID PRICE] }
    let(:transformer) { described_class.new(columns) }

    context 'с валидными данными' do
      let(:data) do
        [
          %w[SBER TQBR 250.5],
          %w[GAZP TQBR 175.3]
        ]
      end

      it 'преобразует данные в массив хешей' do
        result = transformer.transform(data)

        expect(result).to be_an(Array)
        expect(result.size).to eq(2)
      end

      it 'использует символьные ключи в lowercase' do
        result = transformer.transform(data)

        expect(result.first.keys).to all(be_a(Symbol))
        expect(result.first).to have_key(:secid)
        expect(result.first).to have_key(:boardid)
        expect(result.first).to have_key(:price)
      end

      it 'корректно маппит значения на колонки' do
        result = transformer.transform(data)

        expect(result.first).to eq(
          secid: 'SBER',
          boardid: 'TQBR',
          price: '250.5'
        )

        expect(result.last).to eq(
          secid: 'GAZP',
          boardid: 'TQBR',
          price: '175.3'
        )
      end
    end

    context 'с пустыми данными' do
      it 'возвращает пустой массив для []' do
        result = transformer.transform([])
        expect(result).to eq([])
      end
    end

    context 'с разными типами данных в колонках' do
      let(:data) do
        [
          ['SBER', 100, 250.5, true, nil]
        ]
      end
      let(:columns) { %w[SECID VOLUME PRICE ACTIVE EXTRA] }

      it 'сохраняет типы данных' do
        result = transformer.transform(data)

        expect(result.first[:secid]).to eq('SBER')
        expect(result.first[:volume]).to eq(100)
        expect(result.first[:price]).to eq(250.5)
        expect(result.first[:active]).to be(true)
        expect(result.first[:extra]).to be_nil
      end
    end

    context 'с колонками, содержащими специальные символы' do
      let(:columns) { ['SEC_ID', 'BOARD-ID', 'PRICE.VALUE'] }
      let(:data) { [%w[SBER TQBR 250.5]] }

      it 'корректно обрабатывает символы в именах' do
        result = transformer.transform(data)

        expect(result.first).to have_key(:'sec_id')
        expect(result.first).to have_key(:'board-id')
        expect(result.first).to have_key(:'price.value')
      end
    end

    context 'с большим объемом данных' do
      let(:columns) { %w[COL1 COL2 COL3 COL4 COL5] }
      let(:large_data) { Array.new(1000) { %w[val1 val2 val3 val4 val5] } }

      it 'обрабатывает большие массивы данных' do
        result = transformer.transform(large_data)

        expect(result.size).to eq(1000)
        expect(result.first.keys).to eq(%i[col1 col2 col3 col4 col5])
      end

      it 'переиспользует символизированные колонки' do
        # Вызываем трансформацию дважды
        result1 = transformer.transform(large_data)
        result2 = transformer.transform(large_data)

        # Проверяем, что результаты идентичны
        expect(result1).to eq(result2)
      end
    end
  end
end

