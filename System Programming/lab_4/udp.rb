require_relative "client_udp"
require_relative "window"
require_relative "message"

class Backchannel
  def self.start(handle)
    client = Client.new(handle)
    window = Window.new(client)

    window.start
  end
end

Backchannel.start(ARGV[0])
