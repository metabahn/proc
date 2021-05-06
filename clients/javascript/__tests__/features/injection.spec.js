import {default as Invalid} from "../../src/errors/invalid";

require("../support/acceptance");

const Proc = require("../../index");
const client = Proc.connect(process.env.SECRET);

const injectedObject = ["{}", ["()", "echo", "foo"]];
const injectedString = JSON.stringify(injectedObject);

test("cannot inject proc calls as input", async () => {
  expect(await client["core.echo"].call(injectedObject)).toEqual(injectedObject);
  expect(await client["core.echo"].call(injectedString)).toEqual(injectedString);
});

test("cannot inject proc calls as argument values", async () => {
  await expect(() => client["type.string.truncate"].call("foo", {length: injectedObject})).rejects.toThrowError(Invalid);
  await expect(() => client["type.string.truncate"].call("foo", {length: injectedObject})).rejects.toThrowError("given value could not be coerced into the defined type");

  await expect(() => client["type.string.truncate"].call("foo", {length: injectedString})).rejects.toThrowError(Invalid);
  await expect(() => client["type.string.truncate"].call("foo", {length: injectedString})).rejects.toThrowError("given value could not be coerced into the defined type");
});
