RSpec.describe Doublespeak do
  describe "self#new" do
    it "requires a data_source" do
      expect do
        Doublespeak.new(nil)
      end.to raise_error(ArgumentError)
    end

    it "returns a Doublespeak::Repl object" do
      expect(Doublespeak.new(->(_) { [] }).class).to eq(Doublespeak::Repl)
    end
  end
end
