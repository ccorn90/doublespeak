RSpec.describe Doublespeak::Core do
  describe "#render" do
    it "should clear the screen and write the query" do
      core = build_test_core(query: "abcde")

      allow(core.display).to receive(:width).and_return(10)

      expect(core.display).to receive(:move_to_origin).twice
      expect(core.display).to receive(:clear_to_end_of_line).once
      expect(core.display).to receive(:write).with("abcde").once

      core.render
    end
  end

  describe "#finish_up" do
    let(:display) { double("Mock display") }

    before do
      allow(display).to receive(:move_to_origin)
      allow(display).to receive(:clear_to_end_of_line)
      allow(display).to receive(:set_cursor_visible)
      allow(display).to receive(:write).with(any_args).at_least(1.times)
    end

    it "should clear the line" do
      core = build_test_core(display: display)

      core.finish_up
      expect(display).to have_received(:clear_to_end_of_line)
    end

    it "should display the cursor" do
      core = build_test_core(display: display)

      core.finish_up
      expect(display).to have_received(:set_cursor_visible)
    end

    it "should write the selected candidate, after using the selected formatter" do
      formatter = double("Mock formatter")
      allow(formatter).to receive(:call).with("1").and_return("one")
      allow(display).to receive(:format_selected_result).and_return(formatter)

      core = build_test_core(display: display, saved_candidates: [1])

      core.finish_up
      expect(display).to have_received(:write).with("\n")
      expect(display).to have_received(:write).with("one")
    end

    it "should write nothing but a newline if no candidate was selected" do
      core = build_test_core(display: display)

      core.finish_up
      expect(display).to have_received(:write).with("\n")
    end
  end

  describe "#increment_selection" do
    it "has no effect if there are no candidates" do
      core = build_test_core

      core.increment_selection(1)
      expect(core.selected_index).to eq(0)

      core.increment_selection(-1)
      expect(core.selected_index).to eq(0)
    end

    it "moves forward or back in the list" do
      core = build_test_core(saved_candidates: [0, 1, 2, 3, 4], selected_index: 2)

      core.increment_selection(-1)
      expect(core.selected_index).to eq (1)

      core.increment_selection(2)
      expect(core.selected_index).to eq (3)
    end

    it "wraps around from last to first" do
      core = build_test_core(saved_candidates: [0, 1, 2, 3, 4], selected_index: 4)

      core.increment_selection(1)
      expect(core.selected_index).to eq (0)
    end

    it "wraps around from first to last" do
      core = build_test_core(saved_candidates: [0, 1, 2, 3, 4], selected_index: 0)

      core.increment_selection(-1)
      expect(core.selected_index).to eq (4)
    end
  end

  describe "#back_up" do
    it "removes the last character of the query" do
      core = build_test_core(query: "abcd")

      core.back_up
      expect(core.query).to eq("abc")
    end

    it "makes no change if the query is blank" do
      core = build_test_core(query: "")

      core.back_up
      expect(core.query).to eq("")
    end
  end

  describe "#find_candidates" do
    it "resets selected_index" do
      core = build_test_core(selected_index: 2)

      core.find_candidates
      expect(core.selected_index).to eq(0)
    end

    it "calls data_source with the query" do
      core = build_test_core(query: "this is the query")
      allow(core.data_source).to receive(:call).with(any_args).and_return([0, 1])

      core.find_candidates
      expect(core.data_source).to have_received(:call).with("this is the query")
      expect(core.saved_candidates).to eq([0, 1])
    end

    it "doesn't call data_source if the query is the empty string" do
      core = build_test_core(query: "     ")
      allow(core.data_source).to receive(:call).with(any_args)

      core.find_candidates
      expect(core.data_source).not_to have_received(:call)
    end

    it "doesn't call data_source if the query is only whitespace" do
      core = build_test_core(query: "     ")
      allow(core.data_source).to receive(:call).with(any_args)

      core.find_candidates
      expect(core.data_source).not_to have_received(:call)
    end
  end

  describe "#entry" do
    it "appends the given character to the query" do
      core = build_test_core
      allow(core.display).to receive(:width).and_return(10)

      core.entry("a")
      core.entry("b")
      core.entry("c")

      expect(core.query).to eq("abc")
    end

    it "doesn't append the character if the query already fills the screen" do
      core = build_test_core(query: "+" * 10)
      allow(core.display).to receive(:width).and_return(10)

      core.entry("!")

      expect(core.query).to eq("+" * core.display.width)
    end
  end

  def build_test_core(options = {})
    data_source = ->(_) { [0, 1, 2, 3, 4] }
    defaults = {
      display: double("Mock display")
    }

    Doublespeak::Core.new(data_source, defaults.merge(options))
  end
end
