require 'sinatra'
require 'shotgun'

set(:probability) { |value| condition { rand < value } }

get '/win_a_car', :probability => 0.1 do
  "You win are car #{params}"

end

get '/win_a_car' do
  "You lost"
end
