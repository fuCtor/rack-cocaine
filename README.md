[![endorse](https://api.coderwall.com/fuctor/endorsecount.png)](https://coderwall.com/fuctor)
Introducing Rack Cocaine adapter
========================================

Adapter for loading rack applications in Cocaine Cloud as worker.

## Using

You can use command from gem: rackup-cocain
Our you can write custom bootstrap file:
```ruby
    #!/usr/bin/env ruby

    require 'cocaine-rack'
    CocaineRack::Server.start do |worker, app|
        # some another code for worker init
    end
```

Worker don't know self hostname and port.
You can define it through manifest:
```ruby
{
    "slave": "start.rb",
    "environment": {
        "HOSTNAME": "192.168.0.47",
        "PORT": "8080"
    }
}
```
or
```ruby
{
    "slave": "rackup-cocaine",
    "environment": {
        "HOSTNAME": "192.168.0.47",
        "PORT": "8080"
    }
}
```
