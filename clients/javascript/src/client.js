import {default as Argument} from "./argument";
import {default as Callable} from "./callable";
import {default as Enumerator} from "./enumerator";
import {default as ProcError} from "./error";
import {default as serialize} from "./serialize";

import {default as Forbidden} from "./errors/forbidden";
import {default as Invalid} from "./errors/invalid";
import {default as Limited} from "./errors/limited";
import {default as Timeout} from "./errors/timeout";
import {default as Unauthorized} from "./errors/unauthorized";
import {default as Undefined} from "./errors/undefined";

// [public] Connection to proc, configured with an authorization.
//
class Client {
  // [public] Connect a client with an authorization.
  //
  static connect(authorization, options) {
    if (typeof this.fetch === "undefined") {
      if (typeof window !== "undefined") {
        if (typeof window.fetch !== "undefined") {
          this.fetch = true;
        } else {
          // unsupported
        }
      } else {
        try {
          this.fetch = require("fetch-retry")(require("isomorphic-fetch"));
        } catch {
          // unsupported
        }
      }
    }

    let client = Client;
    if (typeof options === "object" && typeof options.client !== "undefined") {
      client = options.client;
    }

    return new client(authorization, options);
  }

  static authorization() {
    try {
      if (typeof process.env.PROC_AUTH !== "undefined") {
        return process.env.PROC_AUTH;
      } else {
        return require("fs").readFileSync(process.env.HOME + "/.proc/auth");
      }
    } catch {
      // unsupported
    }
  }

  constructor(authorization, {host = "proc.dev", scheme = "https"} = {}) {
    if (typeof authorization === "undefined") {
      this.authorization = Client.authorization();
    } else {
      this.authorization = authorization;
    }

    this.uri = `${scheme}://${host}`;

    return new Proxy(this, {
      get(target, key) {
        if(Reflect.has(target, key)) {
          return Reflect.get(target, key);
        }

        return new Callable(key, target);
      }
    });
  }

  // [public] Builds a named argument with options.
  //
  argument(name, options = {}) {
    return new Argument(name, options);
  }

  // [public] Alias for `argument`.
  //
  arg(name, options = {}) {
    return this.argument(name, options);
  }

  // [public] Returns the current rate limit.
  //
  async rateLimit() {
    await this.refreshRateLimit();

    return this.currentRateLimit;
  }

  // [public] Returns the current rate limit window.
  //
  async rateLimitWindow() {
    await this.refreshRateLimit();

    return this.currentRateLimitWindow;
  }

  // [public] Returns the time at which the current rate limit will reset.
  //
  async rateLimitReset() {
    await this.refreshRateLimit();

    return this.currentRateLimitReset;
  }

  // [public] Calls a proc with the given input and arguments.
  //
  // If a function is passed and the proc returns an enumerable, the function will be called for each value.
  //
  async call(proc, input = undefined, args = {}, callback) {
    const body = [];

    if (typeof input !== "undefined") {
      body.push([">>", serialize(input)]);
    }

    for (const key in args) {
      body.push(["$$", key, serialize(args[key])]);
    }

    return this.process(proc, body, input, args, callback);
  }

  async process(proc, body, input, args, callback) {
    const options = {
      method: "POST",
      headers: {
        "accept": "application/vnd.proc+json",
        "content-type": "application/vnd.proc+json",
        "authorization": `bearer ${this.authorization}`
      },
      body: JSON.stringify(body)
    }

    let uriParts = [this.uri];

    if (typeof proc === "string") {
      uriParts = uriParts.concat(proc.split("."));
    }

    const uri = uriParts.join("/");

    let response;
    if (Client.fetch === true) {
      response = await window.fetch(uri, options);
    } else {
      response = await Client.fetch(uri, options);
    }

    this.response = response;

    if (response.status === 200) {
      this.updateRateLimit(
        await response.headers.get("x-rate-limit"),
        await response.headers.get("x-rate-reset")
      );

      const result = await this.extract("<<", response.json());

      if (await response.headers.has("x-cursor")) {
        const cursor = await response.headers.get("x-cursor");

        if (cursor.length > 0) {
          return await new Enumerator(result, callback, () => {
            args["cursor"] = cursor;

            return this.call(proc, input, args);
          });
        } else {
          return new Enumerator(result, callback);
        }
      } else {
        return result;
      }
    } else {
      const {message} = await this.extract("!!", response.json());

      switch (response.status) {
        case 400:
          throw new Invalid(message);
        case 401:
          throw new Unauthorized(message);
        case 403:
          throw new Forbidden(message);
        case 404:
          throw new Undefined(message);
        case 408:
          throw new Timeout(message);
        case 413:
          throw new Invalid(message);
        case 429:
          throw new Limited(message);
        case 500:
          throw new ProcError(message);
        case 508:
          throw new ProcError(message);
        default:
          throw new ProcError("unhandled");
      }
    }
  }

  extract(key, payload) {
    return payload.then((result) => {
      for (const tuple of result) {
        if (tuple[0] === key) {
          return tuple[1];
        }
      }
    });
  }

  updateRateLimit(limit, reset) {
    if (limit) {
      let splitLimit = limit.split(";window=");

      this.currentRateLimit = Number.parseInt(splitLimit[0]);

      switch (splitLimit[1]) {
        case "60":
          this.currentRateLimitWindow = "minute";
          break;
        case "1":
          this.currentRateLimitWindow = "second";
          break;
      }
    } else {
      this.currentRateLimit = null;
      this.currentRateLimitWindow = null;
    }

    if (reset) {
      this.currentRateLimitReset = new Date(reset * 1000);
    } else {
      this.currentRateLimitReset = null;
    }
  }

  async refreshRateLimit() {
    if (typeof this.currentRateLimit === "function") {
      await this.call("core.ping");
    }
  }
};

export default Client;
