class Numeric
  def bound(min,max)
    return min if self < min
    return max if self > max
    self
  end
end
