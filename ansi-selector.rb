require 'io/console'

class AnsiSelector
  def initialize(options)
    @options = options
    @current = 0
  end

  def select
    print

    loop do
      show_single_key
    end
  end

  private

  def clear
    system "tput el1"
    @options[@current].size.times { system "tput cub1" }
  end

  def highlight_line(index)
    print_line(@current, highlight: false)
    print_line(index, highlight: true)
  end

  def print
    @options.each.with_index do |_, index|
      print_line(index, highlight: index == 0)
      @current = index
    end
    STDOUT.print "\n"

    go_to_line(0)
  end

  def print_line(index, highlight:)
    go_to_line(index)
    clear

    if highlight
      system "printf \"$(tput rev)#{@options[index]}$(tput rmso)\""
    else
      STDOUT.print "#{@options[index]}"
    end


    STDOUT.print "  #{@current}"

    @current += 1
  end

  def go_to_line(index)
    return if index == @current

    if index > @current
      (index - @current).times { system "tput cud1" }
    else
      (@current - index).times { system "tput cuu1" }
    end
  end

  def read_char
    STDIN.echo = false
    STDIN.raw!

    input = STDIN.getc.chr
    if input == "\e" then
      input << STDIN.read_nonblock(3) rescue nil
      input << STDIN.read_nonblock(2) rescue nil
    end
  ensure
    STDIN.echo = true
    STDIN.cooked!

    return input
  end

  def show_single_key
    c = read_char

    case c
    when " "
      puts "SPACE"
    when "\t"
      puts "TAB"
    when "\r"
      puts "RETURN"
    when "\n"
      puts "LINE FEED"
    when "\e"
      puts "ESCAPE"
    when "\e[A"
      "UP ARROW"
      highlight_line(@current - 1)
    when "\e[B"
      highlight_line(@current + 1)
    when "\e[C"
      puts "RIGHT ARROW"
    when "\e[D"
      puts "LEFT ARROW"
    when "\177"
      puts "BACKSPACE"
    when "\004"
      puts "DELETE"
    when "\e[3~"
      puts "ALTERNATE DELETE"
    when "\u0003"
      puts "CONTROL-C"
      exit 0
    when /^.$/
      puts "SINGLE CHAR HIT: #{c.inspect}"
    else
      puts "SOMETHING ELSE: #{c.inspect}"
    end
  end
end


AnsiSelector.new(
  ["Trello Issue 1",
    "Trello Issue 2",
    "Trello Issue 3",
    "Trello Issue 4"]
).select
