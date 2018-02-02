module Doublespeak
  class Repl
    def initialize(data_source, options = {})
      raise ArgumentError.new("Must provide a data_source") if data_source.nil?
      @core = Core.new(data_source, options)
    end

    def run
      continue = true

      while continue
        core.render
        core.display.set_cursor_visible(core.query.empty?)

        char = core.display.read
        case char
        when "\r"
          if core.saved_candidates.present?
            continue = false
            core.finish_up
          end

        when "\e[A"
          core.increment_selection(-1)

        when "\e[B"
          core.increment_selection(+1)

        when "\u007F"
          core.back_up
          core.find_candidates

        when /^[a-zA-Z0-9 ]/
          core.entry(char)
          core.find_candidates
        end
      end
    end

    private
    attr_reader :core
  end
end
