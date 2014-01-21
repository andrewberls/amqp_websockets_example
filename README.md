## AMQP/WebSockets example

This is a simple example of using AMQP (RabbitMQ) and WebSockets to send messages
from a server-side API to a set of browser clients in real-time. It uses
[EventMachine](https://github.com/eventmachine/eventmachine),
[em-websocket](https://github.com/igrigorik/em-websocket), and the
[Bunny](https://github.com/ruby-amqp/bunny) RabbitMQ client. The extremely basic
web interface is served by [Sinatra](http://www.sinatrarb.com/).


### Prerequisites
You'll need [RabbitMQ](http://www.rabbitmq.com/) and Ruby installed.

Using [Homebrew](http://brew.sh/):

```
$ brew install rabbitmq
```

Make sure required gems are installed:

```
$ gem install bundler
$ bundle install
```


### Usage

Run each of the following in a separate terminal session:

```
$ rabbitmq-server
$ ruby socketserver.rb
$ rackup config.ru -p 4567
```

Open a browser window, navigate to `localhost:4567`, and open the JS console.
You can connect with as many browser windows when you want - when you open a new
window, the other windows should log a peer join notification.


To test sending AMQP messages:

```
$ ruby producer.rb
```

This sends a stream of data through AMQP and the web socket server down to the browser -
each browser window should log the messages in real-time.
