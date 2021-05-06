require("../support/acceptance");

const Proc = require("../../index");
const client = Proc.connect(process.env.SECRET);

test("yields to call", async () => {
  expect(await client.enum.map.call(["foo", "bar", "baz"], {}, () => {
    return client["type.string.reverse"];
  })).toEqual(["oof", "rab", "zab"]);
});

test("yields to the proc arg", async () => {
  expect(await client.enum.map.call(["foo", "bar", "baz"], {
    proc: client["type.string.reverse"]
  })).toEqual(["oof", "rab", "zab"]);
});

test("yields to callable with", async () => {
  expect(await client.enum.map.with(["foo", "bar", "baz"], {}, () => {
    return client["type.string.reverse"];
  }).call()).toEqual(["oof", "rab", "zab"]);
});
