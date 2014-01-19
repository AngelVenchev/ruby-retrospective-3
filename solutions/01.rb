class Integer
  def prime?
    return false if self < 2
    2.upto(self - 1).none? { |divisor| remainder(divisor).zero? }
  end

  def prime_factors
    return [] if abs < 2
    divisor = 2.upto(abs).find { |divisor| remainder(divisor).zero? }
    [divisor] + (abs / divisor).prime_factors
  end

  def harmonic
    1.upto(self).map { |i| Rational(1, i) }.reduce :+
  end

  def digits
    abs.to_s.chars.map &:to_i
  end
end

class Array
  def frequencies
    each_with_object({}) do |element, hash|
      hash[element] = count element
    end
  end

  def average
    reduce(:+) / count.to_f
  end

  def drop_every(step)
    (1..size).reject { |i| i % step == 0 }.map { |i| self[i-1] }
  end

  def combine_with(other_array)
    return other_array if empty?
    return self if other_array.empty?
    [first] + other_array.combine_with(self[1..-1])
  end
end