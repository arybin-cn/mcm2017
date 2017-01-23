class Numeric
  def bound(min,max)
    if self < min
      yield if block_given?
      return min
    end
    if self > max
      yield if block_given?
      return max
    end
    self
  end
end
