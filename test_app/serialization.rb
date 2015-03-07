require 'json'
require 'pry'

class A
  def initialize(number, string)
    @number, @string = number, string
  end

  def to_s
    "In A:\n  #{@number}, #{@string}"
  end

  def to_json(*args)
    {
      :json_class => self.class.name,
      :data       => { :number => @number, :string => @string }
    }.to_json(*args)
  end

  def self.json_create(obj)
    new(*obj["data"])
  end

  def self.from_json(obj)
    new(*obj["data"])
  end
end

a = A.new(7, 'Hello world')
serialized_obj = Marshal::dump(a)
puts Marshal::load(serialized_obj)

File.open("blah.bin", "w") do |file|
  (1..10).each do |index|
    file.write Marshal::dump(A.new(index, 'Hi, world'))
  end
end

File.open('blah.bin', 'r') do |obj|
  binding.pry
  puts Marshal::load(obj)
end
# puts Marshal::load(File.read('blah.bin'))
