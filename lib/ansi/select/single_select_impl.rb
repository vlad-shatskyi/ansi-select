require_relative 'select_impl'

module Ansi
  class SingleSelectImpl < SelectImpl
    private

    def prefix(index)
      ''
    end

    def space_handler
      # Do nothing
    end

    def carriage_return_handler
      @options[@highlighted_line_index]
    end
  end
end
