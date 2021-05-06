import {default as Composition} from "./composition";
import {default as serialize} from "./serialize";

class Callable {
  constructor(proc, client, input = undefined, args = {}) {
    function callable(cinput = undefined, cargs = {}) {
      return new Callable(
        proc,
        client,
        typeof cinput === "undefined" ? input : cinput,
        Object.assign({}, args, cargs)
      );
    };

    Object.setPrototypeOf(callable, Callable.prototype);

    callable.proc = proc;
    callable.client = client;
    callable.input = input;
    callable.args = args;
    callable.callable = true;

    return new Proxy(callable, {
      get(target, key) {
        if(Reflect.has(target, key)) {
          return Reflect.get(target, key);
        }

        return new Callable([proc, key].join("."), client, input, args);
      }
    });
  }

  // [public] Dispatches this callable context to proc using the client.
  //
  // If a function is passed, it will be called to prior to dispatch and its result passed as a nested context.
  //
  call(input = undefined, args = {}, callback) {
    if (typeof callback === "function") {
      args.proc = callback();
    }

    return this.client.call(
      this.proc,
      typeof input === "undefined" ? this.input : input,
      Object.assign({}, this.args, args)
     );
  }

  // Dispatches this callable context to proc using the client, calling the given function once for each value.
  //
  each(input = undefined, args = {}, callback) {
    return this.client.call(
      this.proc,
      typeof input === "undefined" ? this.input : input,
      Object.assign({}, this.args, args),
      callback
     );
  }

  // Creates a new callable context based on this one, with a new input and/or arguments.
  //
  with(input = undefined, args = {}, callback) {
    if (typeof callback === "function") {
      args.proc = callback();
    }

    return new Callable(
      this.proc,
      this.client,
      typeof input === "undefined" ? this.input : input,
      Object.assign({}, this.args, args)
    );
  }

  // [public] Returns a composition built from this callable context and one or more other callables.
  //
  compose(...others) {
    const composition = new Composition(this.client, this.input);
    composition.push(this);

    for (var i = 0; i < others.length; i++) {
      composition.push(others[i]);
    }

    return composition;
  }

  serialize(unwrapped = false) {
    const serialized = ["()", this.proc];

    if (typeof this.input !== "undefined") {
      serialized.push([">>", serialize(this.input)]);
    }

    for (const key in this.args) {
      serialized.push(["$$", key, serialize(this.args[key])]);
    }

    if (unwrapped) {
      return serialized;
    } else {
      return ["{}", serialized];
    }
  }
};

export default Callable;
