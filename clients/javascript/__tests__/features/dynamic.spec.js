require("../support/acceptance");

const Proc = require("../../index");
const client = Proc.connect(process.env.SECRET);

test("calls a proc dynamically", async () => {
  expect(await client.core.ping.call()).toEqual(true);
});

test("calls a dynamic proc looked up with input", async () => {
  expect(await client.core.echo("foo").call()).toEqual("foo");
});

test("calls a dynamic proc with input", async () => {
  expect(await client.core.echo.call("foo")).toEqual("foo");
});

test("calls a dynamic proc with input that was looked up with input", async () => {
  expect(await client.core.echo("foo").call("bar")).toEqual("bar");
});

test("calls a nested dynamic proc with default input and arguments", async () => {
  expect(await client.type.string.truncate("foo", {length: 1}).call()).toEqual("f");
});

test("calls a nested dynamic proc with default input and arguments given to a previous lookup", async () => {
  expect(await client.type.string("foo", {length: 1}).truncate.call()).toEqual("f");
});

test("calls a nested dynamic proc with default arguments given to a previous lookup and new input", async () => {
  expect(await client.type.string("foo", {length: 1}).truncate("bar").call()).toEqual("b");
});

test("calls a nested dynamic proc with default input and dynamic arguments", async () => {
  expect(await client.type.string.truncate("foo").call(undefined, {length: 1})).toEqual("f");
});

test("calls a nested dynamic proc with default arguments and dynamic input", async () => {
  expect(await client.type.string.truncate(undefined, {length: 1}).call("foo")).toEqual("f");
});

test("calls a nested dynamic proc with dynamic input and arguments", async () => {
  expect(await client.type.string.truncate("foo", {length: 1}).call("bar", {length: 2})).toEqual("ba");
});

describe("object lookup", () => {
  test("supported on the client", async () => {
    expect(await client["core.echo"].call("foo")).toEqual("foo");
  });

  test("supported on a callable", async () => {
    expect(await client.type.string["reverse"].call("foo")).toEqual("oof");
  });
});

describe("using with", () => {
  test("creates a new callable context", async () => {
    expect(await client.core.echo.with("foo").call()).toEqual("foo");
  });

  test("can be overridden like any other callable", async () => {
    expect(await client.core.echo.with("foo").call("bar")).toEqual("bar");
  });
});

describe("using with for a complex case using input and arguments", () => {
  test("can be called", async () => {
    expect(await client.type.string.truncate.with("foo", {length: 1}).call()).toEqual("f");
  });

  test("can have its input overridden", async () => {
    expect(await client.type.string.truncate.with("foo", {length: 1}).call("bar")).toEqual("b");
  });

  test("can have its arguments overridden", async () => {
    expect(await client.type.string.truncate.with("foo", {length: 1}).call(undefined, {length: 2})).toEqual("fo");
  });

  test("can have its input and arguments overridden", async () => {
    expect(await client.type.string.truncate.with("foo", {length: 1}).call("bar", {length: 2})).toEqual("ba");
  });
});
