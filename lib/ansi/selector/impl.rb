require "io/console"

module Ansi
  class Selector
    class Impl
      CODES = {
        standout_mode: `tput rev`,
        exit_standout_mode: `tput rmso`,
        cursor_up: `tput cuu1`,
        cursor_down: `tput cud1`,
        carriage_return_key: `tput cr`
      }

      def initialize(options, formatter, preselected)
        @options = options
        @formatter = formatter
        @highlighted_line_index = 0
        @cursor_line_index = 0

        # Converts options to column-aligned strings.
        formatted = @options.map(&@formatter).map(&method(:Array))
        @formatted ||= formatted.map do |f|
          f.map.with_index do |part, column|
            width = formatted.map { |fm| fm[column] }.compact.map(&:size).max
            part.to_s.ljust(width)
          end.join('  ')
        end
      end

      def select
        print_options
        answer = ask_to_choose
        go_to_line(@options.size)

        answer
      ensure
        tty.close
      end

      private

      # @return [File]
      def tty
        @tty ||= File.open('/dev/tty', 'w+')
      end

      def print_options
        @options.each.with_index do |_, index|
          print_line(index, index == @highlighted_line_index)

          unless index == @options.size - 1
            tty.print $/ # This strange thing is a cross-platform new line.
            @cursor_line_index += 1
          end
        end

        go_to_line(0)
      end

      # @return [String]
      def listen_carefully_to_keyboard
        tty.noecho do
          tty.raw do
            input = tty.getc.chr
            if input == "\e"
              input << tty.read_nonblock(3) rescue nil
              input << tty.read_nonblock(2) rescue nil
            end

            input
          end
        end
      end

      # @return [#to_s]
      def ask_to_choose
        loop do
          input = listen_carefully_to_keyboard

          case input
          when "\u0003", "q"
            exit(0)
          when " "
            space_handler
          when CODES[:carriage_return_key]
            break carriage_return_handler
          when "\e[A", "k", CODES[:cursor_up]
            highlight_line(@highlighted_line_index - 1) unless @highlighted_line_index == 0
          when "\e[B", "j", CODES[:cursor_down]
            highlight_line(@highlighted_line_index + 1) unless @highlighted_line_index == @options.size - 1
          end
        end
      end

      # @param [Fixnum] index
      # @param [Boolean] highlight
      def print_line(index, highlight)
        go_to_line(index)
        text = prefix(index) + @formatted[index]

        if highlight
          tty.print(CODES[:standout_mode] + text + CODES[:exit_standout_mode])
        else
          tty.print(text)
        end
      end

      # @param [Fixnum] index
      def highlight_line(index)
        print_line(@highlighted_line_index, false)
        print_line(index, true)

        @highlighted_line_index = index
      end

      # @param [Fixnum] index
      def go_to_line(index)
        if index == @cursor_line_index
          # do nothing
        elsif index > @cursor_line_index
          (index - @cursor_line_index).times { tty.print CODES[:cursor_down] }
        else
          (@cursor_line_index - index).times { tty.print CODES[:cursor_up] }
        end

        @cursor_line_index = index
        tty.print CODES[:carriage_return_key]
      end

      def prefix(index)
        raise NotImplementedError
      end

      def space_handler
        raise NotImplementedError
      end

      def carriage_return_handler
        raise NotImplementedError
      end
    end
  end
end
