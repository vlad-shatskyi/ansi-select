module Ansi
  class Selector
    # @param [Array<Object>] options
    # @param [Proc] formatter
    #
    # @return [Object] option
    def self.select(options, formatter = default_formatter)
      require_relative "selector/single_impl"

      SingleImpl.new(options, formatter).select
    end

    # @param [Array<Object>] options
    # @param [Proc] formatter
    #
    # @return [Array<Object>] option
    def self.multi_select(options, formatter = default_formatter)
      require_relative "selector/multi_impl"

      MultiImpl.new(options, formatter).select
    end

    private

    # @return [Proc]
    def default_formatter
      ->(option) { option.name }
    end
  end
end
