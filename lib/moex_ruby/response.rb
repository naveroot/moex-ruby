# frozen_string_literal: true

require_relative 'data_transformer'

module MoexRuby
  class Response
    class << self
      def parse(body)
        return [] if blank?(body)

        result = parse_blocks(body)
        normalize_result(result)
      end

      private

      def parse_blocks(body)
        body.each_with_object({}) do |(block_name, block_data), result|
          next unless valid_block?(block_data)

          result[block_name.to_sym] = transform_block(block_data)
        end
      end

      def valid_block?(block_data)
        block_data.is_a?(Hash) &&
          block_data['columns'].is_a?(Array) &&
          block_data['data'].is_a?(Array)
      end

      def transform_block(block_data)
        transformer = DataTransformer.new(block_data['columns'])
        transformer.transform(block_data['data'])
      end

      def normalize_result(result)
        result.size == 1 ? result.values.first : result
      end

      def blank?(value)
        value.nil? || value.empty?
      end
    end

    private_class_method :parse_blocks, :valid_block?, :transform_block, :normalize_result, :blank?
  end
end
