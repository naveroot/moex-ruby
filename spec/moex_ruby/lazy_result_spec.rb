# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MoexRuby::LazyResult do
  let(:enumerator) do
    Enumerator.new do |yielder|
      yielder << { id: 1, name: 'Test 1' }
      yielder << { id: 2, name: 'Test 2' }
      yielder << { id: 3, name: 'Test 3' }
    end
  end
  let(:result) { described_class.new(enumerator) }

  describe '#each' do
    it 'iterates through all items' do
      items = []
      result.each { |item| items << item }
      expect(items.size).to eq(3)
      expect(items.first).to eq({ id: 1, name: 'Test 1' })
    end

    it 'returns enumerator when no block given' do
      expect(result.each).to be_an(Enumerator)
    end
  end

  describe '#to_a' do
    it 'converts to array and caches result' do
      array = result.to_a
      expect(array).to be_an(Array)
      expect(array.size).to eq(3)
      
      cached = result.instance_variable_get(:@cached_array)
      expect(cached).to eq(array)
    end

    it 'returns cached array on subsequent calls' do
      first_call = result.to_a
      second_call = result.to_a
      expect(first_call.object_id).to eq(second_call.object_id)
    end
  end

  describe '#to_ary' do
    it 'converts to array' do
      array = result.to_ary
      expect(array).to be_an(Array)
      expect(array.size).to eq(3)
    end
  end

  describe '#size' do
    it 'returns correct size' do
      expect(result.size).to eq(3)
    end

    it 'uses cached array if available' do
      result.to_a
      expect(result.size).to eq(3)
    end
  end

  describe '#length' do
    it 'returns correct length' do
      expect(result.length).to eq(3)
    end
  end

  describe '#empty?' do
    let(:empty_enumerator) do
      Enumerator.new { |_yielder| }
    end
    let(:empty_result) { described_class.new(empty_enumerator) }

    it 'returns false when not empty' do
      expect(result.empty?).to be(false)
    end

    it 'returns true when empty' do
      expect(empty_result.empty?).to be(true)
    end
  end

  describe '#[]' do
    it 'allows indexed access' do
      expect(result[0]).to eq({ id: 1, name: 'Test 1' })
      expect(result[1]).to eq({ id: 2, name: 'Test 2' })
      expect(result[2]).to eq({ id: 3, name: 'Test 3' })
    end
  end

  describe '#is_a?' do
    it 'returns true for Array' do
      expect(result.is_a?(Array)).to be(true)
      expect(result.kind_of?(Array)).to be(true)
    end

    it 'returns false for other classes' do
      expect(result.is_a?(Hash)).to be(false)
      expect(result.is_a?(String)).to be(false)
    end
  end

  describe 'Array-like methods via method_missing' do
    it 'delegates to array for map' do
      mapped = result.map { |item| item[:id] }
      expect(mapped).to eq([1, 2, 3])
    end

    it 'delegates to array for select' do
      selected = result.select { |item| item[:id] > 1 }
      expect(selected.size).to eq(2)
    end

    it 'delegates to array for first' do
      expect(result.first).to eq({ id: 1, name: 'Test 1' })
    end

    it 'delegates to array for last' do
      expect(result.last).to eq({ id: 3, name: 'Test 3' })
    end
  end

  describe 'Enumerable' do
    it 'includes Enumerable module' do
      expect(described_class.include?(Enumerable)).to be(true)
    end

    it 'can use Enumerable methods' do
      sum = result.reduce(0) { |acc, item| acc + item[:id] }
      expect(sum).to eq(6)
    end
  end

  describe 'caching behavior' do
    it 'caches array when size is called' do
      result.size
      cached = result.instance_variable_get(:@cached_array)
      expect(cached).to be_an(Array)
      expect(cached.size).to eq(3)
    end

    it 'caches array when to_a is called' do
      array = result.to_a
      cached = result.instance_variable_get(:@cached_array)
      expect(cached).to eq(array)
      expect(cached.object_id).to eq(array.object_id)
    end

    it 'reuses cached array on subsequent calls' do
      first_call = result.to_a
      second_call = result.to_a
      expect(first_call.object_id).to eq(second_call.object_id)
    end

    it 'size triggers caching' do
      # Создаем новый enumerator для изоляции теста
      test_enumerator = Enumerator.new do |yielder|
        yielder << { id: 1, name: 'Test 1' }
        yielder << { id: 2, name: 'Test 2' }
        yielder << { id: 3, name: 'Test 3' }
      end
      
      # Создаем новый result с spy на enumerator
      allow(test_enumerator).to receive(:to_a).and_call_original
      new_result = described_class.new(test_enumerator)
      
      # Первый вызов size должен загрузить данные
      expect(test_enumerator).to receive(:to_a).once
      new_result.size
      
      # Второй вызов должен использовать кэш
      new_result.size
    end
  end

  describe 'lazy loading optimizations' do
    it 'does not cache until size or to_a is called' do
      new_result = described_class.new(enumerator)
      expect(new_result.instance_variable_get(:@cached_array)).to be_nil
    end

    it 'first/last work before caching' do
      expect(result.first).to eq({ id: 1, name: 'Test 1' })
      expect(result.last).to eq({ id: 3, name: 'Test 3' })
    end

    it 'first/last(count) work before caching' do
      first_two = result.first(2)
      expect(first_two.size).to eq(2)
      expect(first_two.first).to eq({ id: 1, name: 'Test 1' })
      
      last_two = result.last(2)
      expect(last_two.size).to eq(2)
      expect(last_two.last).to eq({ id: 3, name: 'Test 3' })
    end

    it 'index access works before caching' do
      expect(result[0]).to eq({ id: 1, name: 'Test 1' })
      expect(result[2]).to eq({ id: 3, name: 'Test 3' })
      expect(result[10]).to be_nil
    end
  end

  describe 'enumerator preservation' do
    it 'size() caches and preserves ability to iterate' do
      # Вызываем size, что кэширует данные
      size_before = result.size
      
      # Проверяем, что можем итерироваться после size
      items = []
      result.each { |item| items << item }
      
      expect(items.size).to eq(3)
      expect(size_before).to eq(3)
    end

    it 'allows multiple iterations after first access' do
      result.size # триггерит кэширование
      
      first_iteration = result.to_a
      second_iteration = result.to_a
      
      expect(first_iteration).to eq(second_iteration)
      expect(first_iteration.object_id).to eq(second_iteration.object_id)
    end
  end
end

