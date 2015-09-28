# coding: utf-8

require "io/console"

module Ansi
  class Select


    # @param [Array<#to_s>] options
    #
    # @return [#to_s] option
    def self.select(options)
      SingleSelectImpl.new(options).select
    end

    # @param [Array<#to_s>] options
    #
    # @return [Array<#to_s>] option
    def self.multi_select(options)
      MultiSelectImpl.new(options).select
    end
  end


  class SelectImpl
    CODES = {
      standout_mode: `tput rev`,
      exit_standout_mode: `tput rmso`,
      cursor_up: `tput cuu1`,
      cursor_down: `tput cud1`,
      carriage_return_key: `tput cr`
    }

    def initialize(options)
      @options = options

      @highlighted_line_index = 0
      @cursor_line_index = 0
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
      raise NotImplementedError
    end

    # @param [Fixnum] index
    # @param [Boolean] highlight
    def print_line(index, highlight)
      go_to_line(index)

      if highlight
        tty.print(CODES[:standout_mode] + prefix(index) + @options[index] + CODES[:exit_standout_mode])
      else
        tty.print(prefix(index) + @options[index])
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
  end

  class SingleSelectImpl < SelectImpl
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

    private

    def prefix(index)
      ''
    end
  end

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
