require("../support/acceptance");

const Proc = require("../../index");

test("connects with an authorization", () => {
  expect(() => {
    Proc.connect(process.env.SECRET);
  }).not.toThrow();
});

test("connects with an authorization and host", () => {
  expect(() => {
    Proc.connect(process.env.SECRET, {host: "proc.local"});
  }).not.toThrow();
});

test("connects with an authorization, host, and scheme", () => {
  expect(() => {
    Proc.connect(process.env.SECRET, {host: "proc.local", scheme: "http"});
  }).not.toThrow();
});
