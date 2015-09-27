# coding: utf-8
require 'io/console'
# TODO: use refinements, like string.inverse_video

class AnsiSelector
  def initialize(options)
    @options = options
    @highlighted = 0
    @cursor = 0
  end

  def select
    print

    loop { listen_carefully_to_keyboard }
  end

  private

  def clear
    system "tput el1"
    @options[@highlighted].size.times { system "tput cub1" }
  end

  def highlight_line(index)
    print_line(@highlighted, highlight: false)
    print_line(index, highlight: true)

    @highlighted = index
  end

  def print
    @options.each.with_index do |_, index|
      print_line(index, highlight: index == @highlighted)

      unless index == @options.size - 1
        STDOUT.print "\r\n"
        @cursor += 1
      end
    end
  end

  def print_line(index, highlight:)
    go_to_line(index)
    clear

    if highlight
      system "printf \"$(tput rev)#{@options[index]}$(tput rmso)\""
    else
      STDOUT.print "#{@options[index]}"
    end
  end

  def go_to_line(index)
    return if index == @cursor

    if index > @cursor
      (index - @cursor).times { system "tput cud1" }
    else
      (@cursor - index).times { system "tput cuu1" }
    end

    @cursor = index
  end

  def listen_carefully_to_keyboard
    STDIN.echo = false
    STDIN.raw!

    input = STDIN.getc.chr
    if input == "\e" then
      input << STDIN.read_nonblock(3) rescue nil
      input << STDIN.read_nonblock(2) rescue nil
    end

    keymap.fetch(input, -> {}).call
  end

  def keymap
    {
      "\e[A" => -> { highlight_line(@highlighted - 1) unless @highlighted == 0 },
      "\e[B" => -> { highlight_line(@highlighted + 1) unless @highlighted == @options.size - 1 },
      "\u0003" => -> { exit(0) }
    }
  end
end

AnsiSelector.new(
  ["Trello Issue 1",
    "Trello Issue 2",
    "Trello Issue 3",
    "Trello Issue 4"]
).select
