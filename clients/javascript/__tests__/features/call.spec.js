require("../support/acceptance");

const Proc = require("../../index");
const client = Proc.connect(process.env.SECRET);

test("calls a proc", async () => {
  expect(await client.call("core.ping")).toEqual(true);
});

test("calls a proc with input", async () => {
  expect(await client.call("core.echo", "foo")).toEqual("foo");
});

test("calls a proc with input and arguments", async () => {
  expect(await client.call("type.string.truncate", "foo", { length: 1 })).toEqual("f");
});

test("calls a proc with composed input", async () => {
  expect(await client.call("type.string.truncate", client.core.echo("foo"), { length: 1 })).toEqual("f");
});

test("calls a proc with a composed argument", async () => {
  expect(await client.call("type.string.truncate", "foo", { length: client.core.echo(1) })).toEqual("f");
});
