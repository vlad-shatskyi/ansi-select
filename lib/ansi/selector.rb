module Ansi
  class Selector
    # @param [Array<Object>] options
    # @param [Proc] formatter
    # @param [Fixnum] preselected
    #
    # @return [Object] option
    def self.select(options, formatter: default_formatter, preselected: 0)
      require_relative "selector/single_impl"

      SingleImpl.new(options, formatter, preselected).select
    end

    # @param [Array<Object>] options
    # @param [Proc] formatter
    # @param [Array<Fixnum>] preselected
    #
    # @return [Array<Object>] option
    def self.multi_select(options, formatter: default_formatter, preselected: [])
      require_relative "selector/multi_impl"

      MultiImpl.new(options, formatter, preselected).select
    end

    private

    # @return [Proc]
    def default_formatter
      ->(option) { option.name }
    end
  end
end
