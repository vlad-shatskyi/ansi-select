require "io/console"

module Ansi
  class Selector
    class Impl
      POSITION_SCRIPT_PATH = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "position.sh"))

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
        @columns = terminal_columns

        # Converts options to column-aligned strings.
        formatted = @options.map(&@formatter).map(&method(:Array)).map { |line| line.map(&:to_s).map(&method(:strip_ansi_colors)) }
        @formatted ||= formatted.map do |f|
          f.map.with_index do |part, column|
            width = formatted.map { |fm| fm[column] }.compact.map(&:size).max
            part.ljust(width)
          end.join('  ')
        end

        Signal.trap('SIGWINCH', proc do
          columns = terminal_columns
          if columns < @columns && !all_options_fit?(columns)
            # When a buffer gets narrower, the text that doesn't fit into the screen anymore
            # starts jumping around in a way that makes it hard to predict. In such case we
            # clear everything and re-print options at the beginning of the buffer to
            # simplify things.
            tty.print(`printf '\e[2J'`)
            tty.print(`tput cup 0 0`)
          else
            print_line(0)
          end

          @columns = columns
          print_options
        end)
      end

      def all_options_fit?(columns)
        option_indices.map(&method(:final_text_for_line)).map(&:size).all? { |size| size < columns }
      end

      # @return [Fixnum]
      def terminal_columns
        `tput cols`.to_i
      end

      # @return [Fixnum]
      def terminal_lines
        `tput lines`.to_i
      end

      def select
        print_options
        answer = ask_to_choose
        # We need to reprint here in order to render the lines that are behind the buffer.
        range(@highlighted_line_index, @options.size - 1).each(&method(:print_line))
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
        @options[0...terminal_lines].each.with_index do |_, index|
          print_line(index)

          unless index == @options.size - 1
            tty.print $/ # This global variable is a cross-platform new line.
            @cursor_line_index += 1
          end
        end

        print_line(0)
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
        ctrl_p = "\u0010"
        ctrl_n = "\u000E"
        ctrl_c = "\u0003"

        loop do
          input = listen_carefully_to_keyboard

          case input
          when ctrl_c, "q"
            exit(0)
          when " "
            space_key_handler
          when CODES[:carriage_return_key]
            break carriage_return_handler
          when "\e[A", "k", ctrl_p, CODES[:cursor_up]
            scroll_to(@highlighted_line_index - 1)
          when "\e[B", "j", ctrl_n, CODES[:cursor_down]
            scroll_to(@highlighted_line_index + 1)
          end
        end
      end

      # @param [Fixnum] index
      def scroll_to(index)
        indices_to_reprint = range(@highlighted_line_index, index)
        @highlighted_line_index = indices_to_reprint.last
        indices_to_reprint.each(&method(:print_line))
      end

      # @param [Fixnum] index
      def print_line(index)
        go_to_line(index)
        text = final_text_for_line(index)

        if index == @highlighted_line_index
          tty.print(CODES[:standout_mode] + text + CODES[:exit_standout_mode])
        else
          tty.print(text)
        end
      end

      # @param [Fixnum] index
      def go_to_line(index)
        if index == @cursor_line_index
          # do nothing
        elsif index > @cursor_line_index
          (index - @cursor_line_index).times { tty.print CODES[:cursor_down] }
        else
          row_before_going = cursor_row
          (@cursor_line_index - index).times do |step|
            tty.print(`tput ri`) if step >= row_before_going
            tty.print CODES[:cursor_up]
          end
        end

        @cursor_line_index = index
        tty.print CODES[:carriage_return_key]
      end

      # @param [Fixnum] index
      #
      # @return [String]
      def final_text_for_line(index)
        maybe_add_ellipsis(prefix(index) + @formatted[index])
      end

      # @param [String] text
      def maybe_add_ellipsis(text)
        text.size >= @columns ? text[0...(@columns - 2)] + '…' : text
      end

      # @return [Fixnum]
      def cursor_row
        `bash #{POSITION_SCRIPT_PATH}`.to_i
      end

      # @param [String] text
      #
      # @return [String]
      def strip_ansi_colors(text)
        text.gsub(/\e\[(\d+;?)+m/, '')
      end

      def prefix(index)
        raise NotImplementedError
      end

      def space_key_handler
        raise NotImplementedError
      end

      def carriage_return_handler
        raise NotImplementedError
      end

      def option_indices
        (0...@options.size)
      end

      def range(from, to)
        ((from <= to) ? from.upto(to) : from.downto(to)).to_a.select { |index| (0...@options.size).cover?(index) }
      end
    end
  end
end
