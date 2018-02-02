RSpec.describe String do
  describe "noescape" do
    it "removes formatting escape sequences" do
      expect("str\e3324;23ming".noescape).to eq("string")
      expect("\e23mstring".noescape).to eq("string")
      expect("string\ehkednjkwfm".noescape).to eq("string")
    end
  end

  describe "#ljust_noescape" do
    it "works like normal ljust" do
      expect("01234".ljust_noescape(10)).to eq("01234     ")
    end

    it "doesn't count escape characters when computing the width" do
      expect("\e[37;2m01234\e[0m".ljust_noescape(10)).to eq("\e[37;2m01234\e[0m     ")
    end

    it "accepts an alternate delimiter" do
      expect("01234".ljust_noescape(10, "*")).to eq("01234*****")
    end
  end

  describe "#rjust_noescape" do
    it "works like normal rjust" do
      expect("01234".rjust_noescape(10)).to eq("     01234")
    end

    it "doesn't count escape characters when computing the width" do
      expect("\e[37;2m01234\e[0m".rjust_noescape(10)).to eq("     \e[37;2m01234\e[0m")
    end

    it "accepts an alternate delimiter" do
      expect("01234".rjust_noescape(10, "*")).to eq("*****01234")
    end
  end

  describe "#format_substring" do
    it "doesn't change anything if the substring isn't found" do
      formatter = ->(s) { s.upcase }
      expect("string".format_substring("qq", formatter)).to eq("string")
    end

    it "calls the formatter on the given substring and replaces with the result" do
      formatter = ->(s) { s.upcase }
      expect("string".format_substring("ri", formatter)).to eq("stRIng")
    end

    it "is case sensitive by default" do
      formatter = ->(s) { s.upcase }
      expect("stRing".format_substring("ri", formatter)).to eq("stRing")

      formatter = ->(s) { s.downcase }
      expect("stRIng".format_substring("RI", formatter)).to eq("string")
    end

    it "ignores case if passed downcase: true" do
      formatter = ->(s) { s.upcase }
      expect("stRing".format_substring("ri", formatter, downcase: true)).to eq("stRIng")

      formatter = ->(s) { s.downcase }
      expect("stRIng".format_substring("ri", formatter, downcase: true)).to eq("string")
    end
  end
end
