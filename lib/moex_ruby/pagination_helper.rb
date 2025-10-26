# frozen_string_literal: true

module MoexRuby
  class PaginationHelper
    def self.extract_size(data)
      normalize_data(data).size
    end

    def self.normalize_data(data)
      return [] if blank?(data)

      case data
      when Array then data
      when Hash then data.values.first || []
      else []
      end
    end

    def self.blank?(value)
      value.nil? || (value.respond_to?(:empty?) && value.empty?)
    end

    private_class_method :blank?
  end
end
