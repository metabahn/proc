import {default as Invalid} from "../../src/errors/invalid";
import {default as Undefined} from "../../src/errors/undefined";

require("../support/acceptance");

const Proc = require("../../index");
const client = Proc.connect(process.env.SECRET);

test("composes two procs", async () => {
  const string = client.type.string;
  const composition = string.reverse.compose(string.capitalize);

  expect(await composition.call("foo")).toEqual("Oof");
});

test("composes with arguments", async () => {
  const string = client.type.string;
  const composition = string.reverse.compose(string.truncate(undefined, {length: 2}));

  expect(await composition.call("hello")).toEqual("ol")
});

test("composes with default input and arguments", async () => {
  const string = client.type.string;
  const composition = string.reverse("foo").compose(string.truncate(undefined, {length: 2}));

  expect(await composition.call()).toEqual("oo")
});

test("prefers the given input", async () => {
  const string = client.type.string;
  const composition = string.reverse("foo").compose(string.truncate(undefined, {length: 2}));

  expect(await composition.call("bar")).toEqual("oo")
});

test("calls with callable input", async () => {
  const input = client.core.echo("foo");

  expect(await client.call("type.string.truncate", input, {length: 1})).toEqual("f")
});

test("calls with a callable argument", async () => {
  const length = client.core.echo(1);

  expect(await client.call("type.string.truncate", "foo", {length: length})).toEqual("f")
});

test("calls with callable input that has its own callable input", async () => {
  const input = client.core.echo("foo");
  const capitalized = client.type.string.capitalize(input);

  expect(await client.call("type.string.truncate", capitalized, {length: 1})).toEqual("F")
});

test("calls with a callable argument that has its own callable argument", async () => {
  const bucket = Math.random().toString(36).substring(7);
  const key = Math.random().toString(36).substring(7);

  await client.call("keyv.set", undefined, {bucket: bucket, key: key, value: 2});

  const length = client.keyv.get(undefined, {bucket: bucket, key: client.core.echo(key)});

  expect(await client.call("type.string.truncate", "foo", {length: length})).toEqual("fo")
});

test("calls with composed input", async () => {
  const input = client.core.echo("foo").compose(client.type.string.reverse);

  expect(await client.call("type.string.truncate", input, {length: 1})).toEqual("o")
});

test("calls with a composed argument", async () => {
  const bucket = Math.random().toString(36).substring(7);
  const value = Math.random().toString(36).substring(7);

  await client.call("keyv.set", undefined, {bucket: bucket, key: "yekym", value: value})

  const key = client.core.echo("mykey").compose(client.type.string.reverse);

  expect(await client.keyv.get(undefined, {bucket: bucket, key: key}).call()).toEqual(value);
});

test("calls a composition with a composed input", async () => {
  const composition = client.type.string.reverse.compose(
    client.core.echo.with(
      client.type.string.capitalize.compose(
        client.type.string.truncate(undefined, {length: 2}).compose(
          client.type.string.reverse
        )
      )
    )
  );

  expect(await composition.call("foo")).toEqual("oO");
});

test("fails when a composition calls a proc with invalid arguments", async () => {
  const string = client.type.string;
  const composition = string.reverse("foo").compose(string.truncate);

  await expect(() => composition.call()).rejects.toThrowError(Invalid);
  await expect(() => composition.call()).rejects.toThrowError("invalid argument `length' for `type.string.truncate' (is required)");
});

test("fails when a composition calls an undefined proc", async () => {
  const string = client.type.string;
  const composition = string.reverse("foo").compose(string.missing);

  await expect(() => composition.call()).rejects.toThrowError(Undefined);
});

describe("using with", () => {
  test("calls the composition with the given input", async () => {
    const string = client.type.string;
    const composition = string.reverse.compose(string.truncate(undefined, {length: 1}));

    expect(await composition.with("bar").call()).toEqual("r");
  });

  test("ignores arguments since the scope for use is unknown", async () => {
    const string = client.type.string;
    const composition = string.reverse.compose(string.truncate(undefined, {length: 1}));

    expect(await composition.with("bar", {length: 3}).call()).toEqual("r");
  });
});

describe("composing compositions", () => {
  test("calls the composition", async () => {
    const string = client.type.string;
    const composition1 = client.core.echo("foo").compose(string.reverse);
    const composition2 = string.truncate(undefined, {length: 1}).compose(string.capitalize);
    const composition = composition1.compose(composition2);

    expect(await composition.call()).toEqual("O");
  });
});

describe("composing many", () => {
  test("calls the composition", async () => {
    const string = client.type.string;
    const composition = string.reverse.compose(string.capitalize, string.reverse);

    expect(await composition.call("foo")).toEqual("foO");
  });
});
