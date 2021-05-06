require("../support/acceptance");

const Proc = require("../../index");
const client = Proc.connect(process.env.SECRET);

const bucket = Math.random().toString(36).substring(7);

const keys = [];

beforeAll(async () => {
  const promises = [];

  for (let index = 0; index < 275; index++) {
    keys.push(index.toString());

    promises.push(client.keyv.set.call(undefined, {bucket: bucket, key: index, value: index}));
  }

  await Promise.all(promises);
});

test("enumerates through each", async () => {
  const localKeys = [...keys];

  await client.keyv.scan.each(undefined, {bucket: bucket}, (key) => {
    const keyIndex = localKeys.indexOf(key);
    expect(keyIndex).toBeGreaterThan(-1);
    localKeys.splice(keyIndex, 1);
  });

  expect(localKeys.length).toEqual(0);
});

test("provides a subset of keys through each", async () => {
  const localKeys = [...keys];

  await client.keyv.scan.each(undefined, {bucket: bucket, total: 5}, (key) => {
    const keyIndex = localKeys.indexOf(key);
    expect(keyIndex).toBeGreaterThan(-1);
    localKeys.splice(keyIndex, 1);
  });

  expect(localKeys.length).toEqual(270);
});

test("provides each key to the callback given to each", async () => {
  const localKeys = [...keys];

  const enumerator = await client.keyv.scan.call(undefined, {bucket: bucket});
  await enumerator.each((key) => {
    const keyIndex = localKeys.indexOf(key);
    expect(keyIndex).toBeGreaterThan(-1);
    localKeys.splice(keyIndex, 1);
  });

  expect(localKeys.length).toEqual(0);
});

test("stops enumerating when the callback returns false", async () => {
  const localKeys = [...keys];

  await client.keyv.scan.each(undefined, {bucket: bucket}, (key) => {
    const keyIndex = localKeys.indexOf(key);
    expect(keyIndex).toBeGreaterThan(-1);
    localKeys.splice(keyIndex, 1);

    return false;
  });

  expect(localKeys.length).toEqual(274);
});

test("can be iterated", async () => {
  const localKeys = [...keys];

  const enumerator = await client.keyv.scan.call(undefined, {bucket: bucket});

  for await (const key of enumerator) {
    const keyIndex = localKeys.indexOf(key);
    expect(keyIndex).toBeGreaterThan(-1);
    localKeys.splice(keyIndex, 1);
  }

  expect(localKeys.length).toEqual(0);
});

test("can be converted to an array", async () => {
  const enumerator = await client.keyv.scan.call(undefined, {bucket: bucket});

  const array = await enumerator.toArray();
  expect(array.length).toEqual(keys.length);
});
