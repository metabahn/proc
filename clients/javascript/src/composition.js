import {default as serialize} from "./serialize";

class Composition {
  constructor(client, input = undefined, callables = [], args = {}) {
    this.client = client;
    this.input = input;
    this.callables = callables;
    this.args = args;
    this.composition = true;
  }

  // [public] Dispatches this composition to proc using the client.
  //
  call(input = undefined, args = {}, callback) {
    if (typeof callback === "function") {
      args.proc = callback();
    }

    return this.client.call("core.exec", undefined, {proc: this.with(input, args)});
  }

  // [public] Dispatches this composition to proc using the client, calling the given function once for each value.
  //
  each(input = undefined, args = {}, callback) {
    return this.client.call("core.exec", undefined, {proc: this.with(input, args)}, callback);
  }

  // [public] Creates a new composition based on this one, with a new input and/or arguments.
  //
  with(input = undefined, args = {}, callback) {
    if (typeof callback === "function") {
      args.proc = callback();
    }

    return new Composition(
      this.client,
      typeof input === "undefined" ? this.input : input,
      this.callables.slice(0),
      Object.assign({}, this.args, args)
    );
  }

  // [public] Returns a composition from this composition and one or more other callables.
  //
  compose(...others) {
    const composition = new Composition(this.client, this.input, this.callables.slice(0), Object.assign({}, this.args));

    for (var i = 0; i < others.length; i++) {
      composition.push(others[i]);
    }

    return composition;
  }

  push(callable) {
    if (callable.callable) {
      this.callables.push(callable);
    } else if (callable.composition) {
      this.merge(callable);
    }
  }

  merge(composition) {
    if (composition.composition) {
      this.callables = this.callables.concat(composition.callables);
      Object.assign(this.args, composition.args);
    }
  }

  serialize() {
    const serialized = ["{}"];

    if (typeof this.input !== "undefined") {
      serialized.push([">>", serialize(this.input)]);
    }

    for (const key in this.args) {
      serialized.push(["$$", key, serialize(this.args[key])]);
    }

    for (const callable of this.callables) {
      serialized.push(callable.serialize(true));
    }

    return serialized;
  }
};

export default Composition;
