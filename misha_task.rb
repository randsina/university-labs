def rec(n, array)
  return array if n == 0
  rec(n - 1, array.map.with_index { |e, i| e * (array.size - i - 1) }[0..-2])
end

number = 3
koeff = [5, 2, 4]

array = rec(number, koeff)

number.times { array << 0 }

array
