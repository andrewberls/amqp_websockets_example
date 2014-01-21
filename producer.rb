require 'bunny'

conn = Bunny.new("amqp://guest:guest@localhost:5672")
conn.start

ch = conn.create_channel
ex = ch.default_exchange

QUEUE_NAME = "hello_world"

puts "Sending messages to #{QUEUE_NAME}..."
5.times do |i|
  ex.publish("hello (#{i})", routing_key: QUEUE_NAME)
  sleep 0.5 # seconds
end
puts 'Done.'
