import {default as ASTClient} from "../../src/clients/ast";

require("../support/acceptance");

const Proc = require("../../index");
const client = Proc.connect(process.env.SECRET, {client: ASTClient});

test("builds the ast for simple calls", async () => {
  expect(await client.core.echo("foo").call()).toEqual([["$$", "proc", ["{}", ["()", "core.echo", [">>", ["%%", "foo"]]]]]]);
});

test("builds the ast for compositions", async () => {
  const composition = client.core.echo("foo").compose(client.core.echo());

  expect(await composition.call()).toEqual(
    [
      [
        "$$", "proc", [
          "{}",
          [">>", ["%%", "foo"]],
          ["()", "core.echo", [">>", ["%%", "foo"]]],
          ["()", "core.echo"]
        ]
      ]
    ]
  );
});
