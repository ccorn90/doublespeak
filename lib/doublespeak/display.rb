require 'io/console'
require 'pastel'
require 'tty/reader'

module Doublespeak
  class Display
    attr_reader :format_result, :format_result_textmatch, :format_selected_result,
      :origin_col, :origin_row, :screen_width

    def initialize(options)
      @ostream = options[:ostream] || $stdout
      @istream = options[:istream] || $stdin
      @reader = TTY::Reader.new

      colorizer = Pastel::new
      @format_result = options[:format_result] || colorizer.white.dim.detach
      @format_result_textmatch = options[:format_result_textmatch] || colorizer.cyan.dim.detach
      @format_selected_result = options[:format_selected_result] || colorizer.green.dim.detach

      c, r = *cursor_position
      @origin_col = options[:origin_col] || c
      @origin_row = options[:origin_row] || r
      @screen_width = options[:screen_width] || IO.console.winsize[1]
    end

    def width
      screen_width - origin_col
    end

    def move_to_origin
      write_escaped "[#{origin_row};#{origin_col}H"
    end

    def clear_to_end_of_line
      write_escaped "[K"
    end

    def set_cursor_visible(visible=true)
      write_escaped(visible ? "[?25h" : "[?25l")
    end

    def write(str)
      ostream << str
    end

    def read
      reader.read_char
    end

    private

    attr_reader :ostream, :istream, :reader

    def write_escaped(seq)
      ostream << "\e#{seq}"
      ostream.flush
    end

    def cursor_position
      res = ''
      istream.raw do |stream|
        write_escaped("[6n")
        while (c = stream.getc) != 'R'
          res << c if c
        end
      end
      m = res.match(/(?<row>\d+);(?<column>\d+)/)
      [Integer(m[:column]), Integer(m[:row])]
    end
  end
end
