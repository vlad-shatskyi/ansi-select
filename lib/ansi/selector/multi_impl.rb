require_relative 'impl'

module Ansi
  class Selector
    class MultiImpl < Impl
      def initialize(options)
        super

        # @type [Array<Boolean>]
        @selected_options = []
      end

      private

      def prefix(index)
        @selected_options[index] ? ' [x] ' : ' [ ] '
      end

      def space_handler
        @selected_options[@cursor_line_index] = !@selected_options[@cursor_line_index]
        print_line(@cursor_line_index, true)
      end

      def carriage_return_handler
        @selected_options.map.with_index { |value, index| @options[index] if value }.compact
      end
    end
  end
end
