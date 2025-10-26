# frozen_string_literal: true

module MoexRuby
  class DataTransformer
    def initialize(columns)
      @symbolized_columns = symbolize_columns(columns)
    end

    def transform(data)
      data.map { |row| transform_row(row) }
    end

    private

    def symbolize_columns(columns)
      columns.map { |col| col.downcase.to_sym }
    end

    def transform_row(row)
      @symbolized_columns.zip(row).to_h
    end
  end
end
