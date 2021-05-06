**Superpowers to help you ship web endpoints faster.**

Proc is an all-in-one toolchain for building, deploying, and calling custom behavior from any website or app.

* [Learn more about Proc](https://proc.dev)
* [Browse packages](https://proc.dev/packages)
* [Read the docs](https://proc.dev/docs)
* [Chat with us](https://discord.gg/aRu8qvkCmy)

## Install

Install with `gem install proc`:

```
gem install proc
```

## Usage

Connect to proc using an account secret or limited api key:

```ruby
require "proc"

client = Proc.connect("{your-proc-authorization}")
```

Now you can call procs just like local code:

```ruby
client.type.number.add.call(1, {value: 1});

=> 2
```

Build more complex behavior by composing procs together:

```ruby
time = client.time

composition = time.now >> time.format(string: "%A")

composition.call

=> "Tuesday"
````

Instantly deploy your behavior to a private endpoint and call it from anywhere:

```ruby
client.proc.create.call(name: "day_of_week", proc: composition)

client.self.day_of_week.call

=> "Tuesday"
```

Learn more at [proc.dev](https://proc.dev). See you around!
