**Superpowers to help you ship web endpoints faster.**

Proc is an all-in-one toolchain for building, deploying, and calling custom behavior from any website or app.

* [Learn more about Proc](https://proc.dev)
* [Browse packages](https://proc.dev/packages)
* [Read the docs](https://proc.dev/docs)
* [Chat with us](https://discord.gg/aRu8qvkCmy)

## Install

The easiest way to use the proc client from the browser is through the skypack cdn:

```javascript
(async () => {
  const Proc = await import("https://cdn.skypack.dev/@proc.dev/client");
  const client = Proc.connect("{your-proc-authorization}");

  ...
})();
```

To use the proc client from node, install `@proc.dev/client` using npm, then use it like this:

```javascript
const Proc = require("@proc.dev/client");
const client = Proc.connect("{your-proc-authorization}");

...
```

## Usage

Call procs just like local code:

```javascript
client.type.number.add.call(1, {value: 1});

=> 2
```

Build more complex behaviors with `compose`:

```javascript
let time = client.time;
let composition = time.now.compose(
  time.format(undefined, {string: "%A"})
);

composition.call();

=> "Tuesday"
````

Instantly deploy your behavior to a private endpoint and call it from anywhere:

```javascript
client.proc.create.call(undefined, {name: "day_of_week", proc: composition});

client.self.day_of_week.call();

=> "Tuesday"
```

Learn more at [proc.dev](https://proc.dev). See you around!
