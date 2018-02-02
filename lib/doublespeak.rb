require 'doublespeak/core'
require 'doublespeak/display'
require 'doublespeak/string'
require 'doublespeak/repl'

module Doublespeak
  def self.new(data_source, options = {})
    Doublespeak::Repl.new(data_source, options)
  end
end
