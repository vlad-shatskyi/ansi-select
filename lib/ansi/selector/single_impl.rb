require_relative 'impl'

module Ansi
  class Selector
    class SingleImpl < Impl
      def initialize(options, formatter, preselected)
        super
        @highlighted_line_index = preselected
      end

      private

      def prefix(index)
        ' '
      end

      def space_handler
        # Do nothing
      end

      def carriage_return_handler
        @options[@highlighted_line_index]
      end
    end
  end
end
