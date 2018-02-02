class String
  def noescape
    gsub(%r{\e[^m]*m}, '')
  end

  def ljust_noescape(width, delim=" ")
    self + delim*(width - noescape.length)
  end

  def rjust_noescape(width, delim=" ")
    delim*(width - noescape.length) + self
  end

  def format_substring(substring, formatter, downcase: false)
    index = downcase ? self.downcase.index(substring.downcase) : index(substring)

    if index.nil?
      self
    else
      substring = self[index, substring.length]
      gsub(substring, formatter.call(substring))
    end
  end
end
