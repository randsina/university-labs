class Player

  # initialize your player
  def initialize
    @count = 0
    @result = 'left=1'
    @i = 0
  end

  # process data for each event from tetris-server
  def process_data(data)
    puts '=' * 100
    puts data.class
    hash = {}
    data.split('&').each do |kv|
      key, value = kv.split('=')
      hash[key] = value
    end
    puts hash
    puts hash['glass'].chars.each_slice(10).to_a.reverse.map(&:join).join("\n")
    puts '-' * 100
    puts empty = hash['glass'].index(' ')
    puts hash['glass'][hash['x'].to_i+1]
    if hash['y'].to_i == 17
      @result = 'drop'
      return
    end
    if hash['figure'] = 'I'
      if hash['x'].to_i == empty
        @result = 'drop'
      else
        @result = "left=#{hash['x'].to_i-empty}"
      end
    else
      if (hash['x'].to_i == empty) && (hash['glass'][hash['x'].to_i + 1] == ' ')
        @result = 'drop'
      else
        @result = "left=#{hash['x'].to_i-empty}"
      end
    end

    # @result = 'drop'
  end

  # This method should return string like left=0, right=0, rotate=0, drop'
  def make_step
    @result
  end
end
