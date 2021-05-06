require("../support/acceptance");

const Proc = require("../../index");
const client = Proc.connect(process.env.SECRET);

test("exposes the rate limit", async () => {
  expect(await client.rateLimit()).toEqual(20);
});

test("exposes the rate limit window", async () => {
  expect(await client.rateLimitWindow()).toEqual("minute");
});

test("exposes the rate limit reset", async () => {
  expect(await client.rateLimitReset()).toEqual(null);
});
