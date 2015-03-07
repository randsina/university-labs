require 'benchmark'

n = 30_000_000
str = ['abc', 1, nil, 1.89, :test]
Benchmark.bmbm do |x|
  x.report('length:') { 1.upto(n) { str.length } }
  x.report('size:') { 1.upto(n) { str.size } }
  x.report('count:') { 1.upto(n) { str.count } }
end
