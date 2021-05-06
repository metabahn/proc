import {default as Invalid} from "../../src/errors/invalid";
import {default as Timeout} from "../../src/errors/timeout";
import {default as Unauthorized} from "../../src/errors/unauthorized";
import {default as Undefined} from "../../src/errors/undefined";

require("../support/acceptance");

const Proc = require("../../index");
const client = Proc.connect(process.env.SECRET);

test("throws when secret is missing", async () => {
  await expect(() => Proc.connect().call("core.ping")).rejects.toThrowError(Unauthorized);
  await expect(() => Proc.connect().call("core.ping")).rejects.toThrowError("authorization is invalid");
});

test("throws when secret is invalid", async () => {
  await expect(() => Proc.connect("12321").call("core.ping")).rejects.toThrowError(Unauthorized);
  await expect(() => Proc.connect("12321").call("core.ping")).rejects.toThrowError("authorization is invalid");
});

test("throws when proc does not exist", async () => {
  await expect(() => client.call("foo.bar.baz")).rejects.toThrowError(Undefined);
  await expect(() => client.call("foo.bar.baz")).rejects.toThrowError("undefined proc `foo.bar.baz'");
});

test("throws when input is of the wrong type", async () => {
  await expect(() => client.call("type.string.truncate", ["foo"])).rejects.toThrowError(Invalid);
  await expect(() => client.call("type.string.truncate", ["foo"])).rejects.toThrowError("proc `type.string.truncate' does not accept the given input");
});

test("throws when token does not have a necessary ability", async () => {
  const authorization = await client.call("auth.create", { abilities: ["string"] });

  await expect(() => Proc.connect(authorization).call("core.ping")).rejects.toThrowError(Unauthorized);
  await expect(() => Proc.connect(authorization).call("core.ping")).rejects.toThrowError("authorization does not have the ability to access proc `core.ping'");
});

test("throws when the server is unreachable", async () => {
  await expect(() => Proc.connect(process.env.SECRET, {host: "not-a-valid-host"}).call("core.ping")).rejects.toThrowError(/request to https:\/\/not-a-valid-host\/core\/ping failed/);
});

test.todo("throws when the user is being rate limited");

test("throws when the call exceeds the max execution time", async () => {
  await expect(() => client.call("core.sleep", undefined, {seconds: 6})).rejects.toThrowError(Timeout);
  await expect(() => client.call("core.sleep", undefined, {seconds: 6})).rejects.toThrowError("forced to stop after 5s");
});

test("throws the request is too large", async () => {
  await expect(() => client.call("core.echo", (new Array(1024 * 128)).join("foo"))).rejects.toThrowError(Invalid);
  await expect(() => client.call("core.echo", (new Array(1024 * 128)).join("foo"))).rejects.toThrowError("request size exceeded the allowed 131072 bytes");
});

describe("unknown proc discovery", () => {
  test("lists procs at root", async () => {
    await expect(() => client.call()).rejects.toThrowError(Undefined);
    await expect(() => client.call()).rejects.toThrowError("undefined proc; try one of: auth, core, enum, keyv, math, proc, rand, time, type");
  });

  test("lists procs at a nested namespace", async () => {
    await expect(() => client.call("type")).rejects.toThrowError(Undefined);
    await expect(() => client.call("type")).rejects.toThrowError("undefined proc `type'; try one of: type.array, type.hash, type.number, type.string");
  });

  test("lists procs at a deeply nested namespace", async () => {
    await expect(() => client.call("type.string.blah")).rejects.toThrowError(Undefined);
    await expect(() => client.call("type.string.blah")).rejects.toThrowError("undefined proc `type.string.blah'; try one of: type.string, type.string.append, type.string.capitalize, type.string.characters, type.string.chomp, type.string.downcase, type.string.empty, type.string.equal, type.string.integer, type.string.length, type.string.prepend, type.string.reverse, type.string.swapcase, type.string.truncate, type.string.upcase");
  });
});
