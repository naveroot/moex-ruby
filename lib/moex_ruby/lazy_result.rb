# frozen_string_literal: true

module MoexRuby
  class LazyResult
    include Enumerable

    def initialize(enumerator)
      @enumerator = enumerator
      @cached_array = nil
    end

    def each(&block)
      if block_given?
        return @cached_array.each(&block) if @cached_array

        @enumerator.each(&block)
      else
        to_enum(:each)
      end
    end

    def to_a
      @cached_array ||= @enumerator.to_a
    end

    def to_ary
      to_a
    end

    def size
      return @cached_array.size if @cached_array
      @cached_array = @enumerator.to_a
      @cached_array.size
    end

    def length
      size
    end

    def empty?
      return @cached_array.empty? if @cached_array

      size.zero?
    end

    def [](index)
      return @cached_array[index] if @cached_array

      to_a[index]
    end

    def first(count = nil)
      if @cached_array
        return count ? @cached_array.first(count) : @cached_array.first
      end

      count ? to_a.first(count) : to_a.first
    end

    def last(count = nil)
      if @cached_array
        return count ? @cached_array.last(count) : @cached_array.last
      end

      count ? to_a.last(count) : to_a.last
    end

    def is_a?(klass)
      super || klass == Array
    end

    def kind_of?(klass)
      is_a?(klass)
    end

    def to_enum(method = :each, *args)
      @enumerator.to_enum(method, *args)
    end

    def method_missing(name, *args, &block)
      return super unless to_a.respond_to?(name)

      to_a.public_send(name, *args, &block)
    end

    def respond_to_missing?(name, include_private = false)
      to_a.respond_to?(name, include_private) || super
    end

    private

    attr_reader :enumerator
  end
end

