# coding: utf-8

require "ansi/select/version"
require "io/console"

# TODO: support ruby 1.9.
module Ansi
  class Select
    STANDOUT_MODE_CODE = `tput rev`
    EXIT_STANDOUT_MODE_CODE = `tput rmso`
    CURSOR_UP_CODE = `tput cuu1`
    CURSOR_DOWN_CODE = `tput cud1`
    CARRIAGE_RETURN_KEY_CODE = `tput cr`

    # @param [Array<#to_s>] options
    def initialize(options)
      @options = options
      @highlighted = 0
      @cursor = 0
    end

    def select
      File.open('/dev/tty', 'w+') do |tty|
        print_options(tty)
        answer = ask_to_choose(tty)
        go_to_line(@options.size, stream: tty)
        answer
      end
    end

    private

    def ask_to_choose(tty)
      loop do
        input = listen_carefully_to_keyboard(tty)

        case input
        when "\u0003", "q"
          exit(0)
        when CARRIAGE_RETURN_KEY_CODE, " "
          break @options[@highlighted]
        when "\e[A", "k", CURSOR_UP_CODE
          highlight_line(@highlighted - 1, stream: tty) unless @highlighted == 0
        when "\e[B", "j", CURSOR_DOWN_CODE
          highlight_line(@highlighted + 1, stream: tty) unless @highlighted == @options.size - 1
        end
      end
    end

    def highlight_line(index, stream:)
      print_line(@highlighted, highlight: false, stream: stream)
      print_line(index, highlight: true, stream: stream)

      @highlighted = index
    end

    def print_options(tty)
      @options.each.with_index do |_, index|
        print_line(index, highlight: index == @highlighted, stream: tty)

        unless index == @options.size - 1
          tty.print $/ # This strange thing is a cross-platform new line.
          @cursor += 1
        end
      end

      go_to_line(0, stream: tty)
    end

    def print_line(index, highlight:, stream:)
      go_to_line(index, stream: stream)

      if highlight
        stream.print "#{STANDOUT_MODE_CODE}#{@options[index]}#{EXIT_STANDOUT_MODE_CODE}"
      else
        stream.print @options[index]
      end
    end

    def go_to_line(index, stream:)
      if index == @cursor
        # do nothing
      elsif index > @cursor
        (index - @cursor).times { stream.print CURSOR_DOWN_CODE }
      else
        (@cursor - index).times { stream.print CURSOR_UP_CODE }
      end

      @cursor = index
      stream.print CARRIAGE_RETURN_KEY_CODE
    end

    # @param [File] tty
    def listen_carefully_to_keyboard(tty)
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
  end
end
