require 'eventmachine'
require 'em-websocket'
require 'bunny'
require 'logger'
require 'json'

trap(:INT) do
  puts "Stopping..."
  EM.stop
end


CLIENT_LOG_INTERVAL = 5 # seconds

$clients = [] # :(

def peers(client)
  $clients.reject { |c| client == c }
end

def format_msg(type, msg)
  { type: type, msg: msg }.to_json
end


EM.run do
  logger = Logger.new(STDOUT)
  conn   = Bunny.new("amqp://guest:guest@localhost:5672")
  conn.start

  ch = conn.create_channel
  q  = ch.queue("hello_world", auto_delete: true)

  # When we get an AMQP message, send it to all clients
  q.subscribe do |delivery_info, metadata, payload|
    $clients.each { |p| p.send(format_msg(:message, payload)) }
  end

  EM.add_periodic_timer(CLIENT_LOG_INTERVAL) do
    logger.info("#{$clients.size} clients connected")
  end

  logger.info("Starting WebSocket server...")

  EM::WebSocket.run(host: '0.0.0.0', port: 9000) do |conn|
    conn.onopen do |handshake|
      logger.info("OPEN => client signature: #{conn.signature}")
      $clients << conn
      peers(conn).each { |p| p.send(format_msg(:join, "Someone joined")) }
    end

    conn.onclose do
      logger.info("CLOSE => client signature: #{conn.signature}")
      $clients.delete(conn)
    end

    conn.onmessage do |msg|
      logger.info("Received message: #{msg}")
      peers(conn).each { |p| p.send(format_msg(:message, msg)) }
    end
  end
end

