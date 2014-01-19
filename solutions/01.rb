class Integer
  def prime?
    self > 1 and (2...self).none? { |i| self % i == 0}
  end

  def factor_count(factor)
    return 0 unless abs % factor == 0
    1 + (abs / factor).factor_count(factor)
  end

  def prime_factors
    (2..abs).select(&:prime?).inject([]) do |result, i|
      result += [i] * factor_count(i)
    end
  end

  def harmonic
    (1..self).map { |i| 1/i.to_r }.inject :+
  end

  def digits
    abs.to_s.chars.map(&:to_i)
  end
end

class Array
  def frequencies
    each_with_object({}) do |element, hash|
      hash[element] = count element
    end
  end

  def average
    inject(:+) / count.to_f
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