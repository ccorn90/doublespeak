RSpec.describe Doublespeak::Display do
  let(:cursor_position_chars) { "\e[9;10R".split("") }

  let(:ostream) {
    ostream = double
    allow(ostream).to receive(:<<).with(any_args)
    allow(ostream).to receive(:flush)
    ostream
  }

  let(:istream) {
    istream = double
    allow(istream).to receive(:raw).and_yield(istream)
    allow(istream).to receive(:getc).and_return(*cursor_position_chars)
    istream
  }

  describe "format_result" do
    it "defaults to a formatter that turns the text white and dim" do
      display = Doublespeak::Display.new(
        ostream: ostream,
        istream: istream
      )

      expect(display.format_result.call("text")).to eq("\e[37;2mtext\e[0m")
    end
  end

  describe "format_result_textmatch" do
    it "defaults to a formatter that turns the text cyan and dim" do
      display = Doublespeak::Display.new(
        ostream: ostream,
        istream: istream
      )

      expect(display.format_result_textmatch.call("text")).to eq("\e[36;2mtext\e[0m")
    end
  end

  describe "format_selected_result" do
    it "defaults to a formatter that turns the text green and dim" do
      display = Doublespeak::Display.new(
        ostream: ostream,
        istream: istream
      )

      expect(display.format_selected_result.call("text")).to eq("\e[32;2mtext\e[0m")
    end
  end

  describe "format_result" do
    it "defaults to a formatter that turns the text white and dim" do
      display = Doublespeak::Display.new(
        ostream: ostream,
        istream: istream
      )

      expect(display.format_result.call("text")).to eq("\e[37;2mtext\e[0m")
    end
  end

  describe "inferred parameters" do
    it "sets origin_row" do
      display = Doublespeak::Display.new(
        ostream: ostream,
        istream: istream
      )

      expect(display.origin_row).to eq(9)
    end

    it "sets origin_col" do
      display = Doublespeak::Display.new(
        ostream: ostream,
        istream: istream
      )

      expect(display.origin_col).to eq(10)
    end

    it "sets screen_width" do
      mock = double
      allow(mock).to receive(:winsize).and_return([0, 100])
      allow(IO).to receive(:console).and_return(mock)

      display = Doublespeak::Display.new(
        ostream: ostream,
        istream: istream
      )

      expect(display.screen_width).to eq(100)
    end
  end

  describe "#width" do
    it "reflects the screen width less the origin column" do
      display = Doublespeak::Display.new(
        ostream: ostream,
        istream: istream,
        screen_width: 100,
        origin_col: 10
      )

      expect(display.width).to eq(90)
    end
  end

  describe "#move_to_origin" do
    it "writes the escape sequence to set the cursor position" do
      display = Doublespeak::Display.new(
        ostream: ostream,
        istream: istream,
        origin_row: 10,
        origin_col: 5
      )

      display.move_to_origin

      expect(ostream).to have_received(:<<).with("\e[10;5H")
      expect(ostream).to have_received(:flush).exactly(2).times
    end
  end

  describe "#clear_to_end_of_line" do
    it "writes the proper escape sequence" do
      display = Doublespeak::Display.new(
        ostream: ostream,
        istream: istream
      )

      display.clear_to_end_of_line

      expect(ostream).to have_received(:<<).with("\e[K")
      expect(ostream).to have_received(:flush).exactly(2).times
    end
  end

  describe "#set_cursor_visible" do
    it "writes the proper escape sequence to show the cursor" do
      display = Doublespeak::Display.new(
        ostream: ostream,
        istream: istream
      )

      display.set_cursor_visible

      expect(ostream).to have_received(:<<).with("\e[?25h")
      expect(ostream).to have_received(:flush).exactly(2).times
    end

    it "writes the proper escape sequence to hide the cursor" do
      display = Doublespeak::Display.new(
        ostream: ostream,
        istream: istream
      )

      display.set_cursor_visible(false)

      expect(ostream).to have_received(:<<).with("\e[?25l")
      expect(ostream).to have_received(:flush).exactly(2).times
    end
  end

  describe "#write" do
    it "sends the given text to output stream" do
      display = Doublespeak::Display.new(
        ostream: ostream,
        istream: istream
      )

      display.write("hip to be square")

      expect(ostream).to have_received(:<<).with("hip to be square")
    end
  end

  describe "#read" do
    it "reads a single character from the input stream" do
      reader = double("tty-reader")
      allow(reader).to receive(:read_char).and_return(*["a", "b", "c"])
      allow(TTY::Reader).to receive(:new).and_return(reader)

      display = Doublespeak::Display.new(
        ostream: ostream,
        istream: istream
      )

      expect(display.read).to eq("a")
      expect(display.read).to eq("b")
      expect(display.read).to eq("c")
    end
  end
end
