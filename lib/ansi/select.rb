# coding: utf-8

require "ansi/select/version"
require "io/console"

# TODO: support ruby 1.9.
module Ansi
  class Select
    CODES = {
      standout_mode: `tput rev`,
      exit_standout_mode: `tput rmso`,
      cursor_up: `tput cuu1`,
      cursor_down: `tput cud1`,
      carriage_return_key: `tput cr`
    }

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
        when CODES[:carriage_return_key], " "
          break @options[@highlighted]
        when "\e[A", "k", CODES[:cursor_up]
          highlight_line(@highlighted - 1, stream: tty) unless @highlighted == 0
        when "\e[B", "j", CODES[:cursor_down]
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
        stream.print "#{CODES[:standout_mode]}#{@options[index]}#{CODES[:exit_standout_mode]}"
      else
        stream.print @options[index]
      end
    end

    def go_to_line(index, stream:)
      if index == @cursor
        # do nothing
      elsif index > @cursor
        (index - @cursor).times { stream.print CODES[:cursor_down] }
      else
        (@cursor - index).times { stream.print CODES[:cursor_up] }
      end

      @cursor = index
      stream.print CODES[:carriage_return_key]
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
