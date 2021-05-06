import {default as Invalid} from "../../src/errors/invalid";

require("../support/acceptance");

const Proc = require("../../index");
const client = Proc.connect(process.env.SECRET);

test("does not pass undefined input to calls", async () => {
  await expect(() => client.call("core.echo")).rejects.toThrowError(Invalid);
  await expect(() => client.call("core.echo")).rejects.toThrowError("invalid input for `core.echo' (was undefined)");
});

test("does not pass undefined input to compositions", async () => {
  const composition = client.core.echo.compose(client.core.echo);

  await expect(() => composition.call()).rejects.toThrowError(Invalid);
  await expect(() => composition.call()).rejects.toThrowError("invalid input for `core.echo' (was undefined)");
});

test("does not confuse null with undefined", async () => {
  expect(await client.call("core.echo", null)).toEqual(null);
});
