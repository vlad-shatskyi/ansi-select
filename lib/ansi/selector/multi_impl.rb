require_relative 'impl'

module Ansi
  class Selector
    class MultiImpl < Impl
      def initialize(options)
        super
        # TODO: rename chosen.
        @chosen = []
      end

      private

      def prefix(index)
        @chosen[index] ? '[x] ' : '[ ] '
      end

      def space_handler
        @chosen[@cursor_line_index] = !@chosen[@cursor_line_index]
        print_line(@cursor_line_index, true)
      end

      def carriage_return_handler
        @chosen.map.with_index { |value, index| @options[index] if value }.compact
      end
    end
  end
end
