require_relative 'select_impl'

module Ansi
  class MultiSelectImpl < SelectImpl
    def initialize(options)
      super
      @chosen = []
    end

    private

    # @return [#to_s]
    def ask_to_choose
      loop do
        input = listen_carefully_to_keyboard

        case input
        when "\u0003", "q"
          exit(0)
        when " "
          if @chosen
            @chosen[@cursor_line_index] = !@chosen[@cursor_line_index]
            print_line(@cursor_line_index, true)
          end
        when CODES[:carriage_return_key]
          if @chosen
            break @chosen.map.with_index { |value, index| @options[index] if value }.compact
          else
            break @options[@highlighted_line_index]
          end
        when "\e[A", "k", CODES[:cursor_up]
          highlight_line(@highlighted_line_index - 1) unless @highlighted_line_index == 0
        when "\e[B", "j", CODES[:cursor_down]
          highlight_line(@highlighted_line_index + 1) unless @highlighted_line_index == @options.size - 1
        end
      end
    end

    def prefix(index)
      @chosen[index] ? '[x] ' : '[ ] '
    end
  end
end
