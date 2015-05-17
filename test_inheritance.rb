require 'benchmark'

class Foo
  private
  def bar
    'Hello world'
  end
end

f = Foo.new

n = 5000000
Benchmark.bmbm do |x|
  # x.report('.') { n.times { f.bar } }
  x.report('call') { n.times { f.method(:bar).call } }
  x.report('send') { n.times { f.send(:bar) } }
end
