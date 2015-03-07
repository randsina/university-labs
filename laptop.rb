#!/usr/bin/env ruby
class Laptop
  def initialize(company, price, hours, weight)
    @company, @price, @hours, @weight = company, price, hours, weight
  end

  def to_s
    "Laptop: #{@company.center}, with #{@hours.center} and #{@weight.center}. Price - #{@price.center}"
  end
end
