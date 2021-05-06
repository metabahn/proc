import {default as Invalid} from "../../src/errors/invalid";

require("../support/acceptance");

const Proc = require("../../index");
const client = Proc.connect(process.env.SECRET);

describe("using an argument reference as input in a call", () => {
  test("uses the given argument as input", async () => {
    const proc = client.core.echo(client.argument("foo"));

    expect(await proc.call(undefined, {foo: "foo"})).toEqual("foo");
  });
});

describe("using an argument reference to require an argument in a call", () => {
  let proc = client.type.string.truncate(undefined, {length: client.argument("truncate_to")});

  test("uses the given argument in the call", async () => {
    expect(await proc.call("foo", {truncate_to: 2})).toEqual("fo")
  });

  test("uses the given argument using with", async () => {
    expect(await proc.with(undefined, {truncate_to: 2}).call("foo")).toEqual("fo")
  });

  test("uses complex argument values", async () => {
    expect(await proc.call("foo", {truncate_to: client.core.echo(2)})).toEqual("fo")
  });

  test("fails when the argument is not given", async () => {
    await expect(() => proc.call("foo")).rejects.toThrowError(Invalid);
    await expect(() => proc.call("foo")).rejects.toThrowError("invalid argument `truncate_to' for `type.string.truncate' (is required)");
  });

  test("prefers the given argument", async () => {
    proc = client.type.string.truncate(undefined, {length: client.argument("length")})

    expect(await proc.call("foo", {length: 2})).toEqual("fo");
  });
});

describe("using an argument reference as input in a composition", () => {
  let proc = client.type.string.reverse(client.argument("foo")).compose(client.type.string.truncate(undefined, {length: 2}));

  test("uses the given argument value as input", async () => {
    expect(await proc.call(undefined, {foo: "bar"})).toEqual("ra")
  });

  test("uses the given argument value as input using with", async () => {
    expect(await proc.with(undefined, {foo: "bar"}).call()).toEqual("ra")
  });

  test("uses complex argument values", async () => {
    expect(await proc.call(undefined, {foo: client.core.echo("bar")})).toEqual("ra")
  });
});

describe("using an argument reference to require an argument in a composition", () => {
  let proc = client.type.string.reverse.compose(
    client.type.string.truncate(undefined, {length: client.argument("truncate_to")})
  );

  test("uses the given argument in the composition", async () => {
    expect(await proc.call("foo", {truncate_to: 1})).toEqual("o");
  });

  test("uses the given argument in the composition using with", async () => {
    expect(await proc.with(undefined, {truncate_to: 1}).call("foo")).toEqual("o");
  });

  test("uses complex argument values", async () => {
    expect(await proc.call("foo", {truncate_to: client.core.echo(1)})).toEqual("o");
  });

  test("fails when the argument is not passed", async () => {
    await expect(() => proc.call("foo")).rejects.toThrowError(Invalid);
    await expect(() => proc.call("foo")).rejects.toThrowError("invalid argument `truncate_to' for `type.string.truncate' (is required)");
  });

  test("prefers the given argument", async () => {
    proc = client.type.string.reverse.compose(
      client.type.string.truncate(undefined, {length: client.argument("length")})
    );

    expect(await proc.call("foo", {length: 1})).toEqual("o");
  });
});

describe("passing a complex value to an argument reference in a composition", () => {
  let proc = client.type.string.reverse.compose(
    client.type.string.truncate(undefined, {length: client.argument("truncate_to")})
  );

  test("resolves the complex value correctly", async () => {
    expect(await proc.call("foo", {truncate_to: client.core.echo(1)})).toEqual("o");
  });
});

describe("using an argument reference with a default value in a composition", () => {
  let proc = client.type.string.reverse.compose(
    client.type.string.truncate(undefined, {length: client.argument("truncate_to", {default: 2})})
  );

  test("uses argument references for a composition", async () => {
    expect(await proc.call("foo", {truncate_to: 1})).toEqual("o");
  });

  test("falls back to the default value when not passed", async () => {
    expect(await proc.call("foo")).toEqual("oo");
  });
});

describe("using an argument reference with a complex default value in a composition", () => {
  let echo = client.core.echo(2);
  let proc = client.type.string.reverse.compose(
    client.type.string.truncate(undefined, {length: client.argument("truncate_to", {default: echo})})
  );

  test("falls back to the default value when not passed", async () => {
    expect(await proc.call("foo")).toEqual("oo");
  });
});

describe("coercing an argument reference", () => {
  test("coerces the value correctly", async () => {
    expect(await client.core.echo(client.arg("foo", {type: "integer"})).call(undefined, {foo: "1"})).toEqual(1);
  });
});

describe("using the convenience method to define an argument reference", () => {
  let proc = client.type.string.reverse.compose(
    client.type.string.truncate(undefined, {length: client.arg("truncate_to")})
  );

  test("uses the argument reference", async () => {
    expect(await proc.call("foo", {truncate_to: 1})).toEqual("o");
  });
});
