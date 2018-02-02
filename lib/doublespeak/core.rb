module Doublespeak
  class Core
    attr_reader :data_source, :format_data, :display
    attr_reader :query, :selected_index, :saved_candidates

    def initialize(data_source, options = {})
      @data_source = data_source
      @format_data = options[:format_data] || ->(x) { "#{x}" }

      @display = options[:display] || Display.new(options)

      @query = options[:query] || ""
      @selected_index = options[:selected_index] || 0
      @saved_candidates = options[:saved_candidates] || []
    end

    def render
      display.move_to_origin
      display.clear_to_end_of_line

      display.write (query + status_line)

      display.move_to_origin
    end

    def finish_up
      display.move_to_origin
      display.clear_to_end_of_line
      display.set_cursor_visible

      display.write display.format_selected_result.call(format_data.call(candidate)) unless candidate.nil?
      display.write "\n"
    end

    def increment_selection(i)
      @selected_index = selected_index + i
      if saved_candidates.size == 0
        @selected_index = 0
      elsif selected_index < 0
        @selected_index = saved_candidates.size - 1
      elsif selected_index >= saved_candidates.size
        @selected_index = 0
      end
    end

    def back_up
      query.chop!
    end

    def find_candidates
      @selected_index = 0
      @saved_candidates = query.strip.to_s.empty? ? [] : data_source.call(query)
    end

    def entry(c)
      if query.length < display.width
        query.concat(c)
      end
    end

    private

    def status_line
      if saved_candidates.empty?
        ""
      else
        width = display.width - query.length + 1
        display.format_result.call(candidate_text + selected_index_text).rjust_noescape(width)
      end
    end

    def candidate_text
      max_width = saved_candidates.map { |c| format_data.call(c).length }.max

      format_data.call(candidate)
        .ljust_noescape(max_width)
        .format_substring(query, display.format_result_textmatch, downcase: true)
    end

    def selected_index_text
      return "" if saved_candidates.length <= 1

      "(#{selected_index+1}/#{saved_candidates.length})".rjust(8, " ")
    end

    def candidate
      saved_candidates[selected_index]
    end
  end
end
