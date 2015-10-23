module Ansi
  class Selector
    class << self
      # @param [Array<Object>] options
      # @param [Proc] formatter
      # @param [Fixnum] preselected
      #
      # @return [Object] option
      def select(options, formatter: default_formatter, preselected: 0)
        require_relative "selector/single_impl"

        SingleImpl.new(options, formatter, preselected).select
      end

      # @param [Array<Object>] options
      # @param [Proc] formatter
      # @param [Array<Fixnum>] preselected
      #
      # @return [Array<Object>] option
      def multi_select(options, formatter: default_formatter, preselected: [])
        require_relative "selector/multi_impl"

        MultiImpl.new(options, formatter, preselected).select
      end

      private

      # @return [Proc]
      def default_formatter
        :to_s.to_proc
      end
    end
  end
end
