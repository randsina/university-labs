# encoding: utf-8

require 'codenjoy_connection'
require File.expand_path('../player', __FILE__)

host_ip = '10.0.0.190' # ip of host with running tetris-server
port = '8080' # this port is used for communication between your client and tetris-server
user = 'randsina' # your username, use the same for registration on tetris-server

opts = {:username => user, :host=> host_ip, :port => port, :game_url => 'tetris-contest/ws?'}

player = Player.new
CodenjoyConnection.play(player,opts)
