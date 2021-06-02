import {default as Unauthorized} from "../../src/errors/unauthorized";

require("../support/acceptance");

const Proc = require("../../index");
const fs = require("fs");

const authDirPath = process.env.HOME + "/.proc";
const authFilePath = authDirPath + "/auth";

let existingAuthFileContents = undefined;

function removeAuthFile() {
  backupAuthFile();

  fs.unlinkSync(authFilePath);
}

function replaceAuthFile(contents = process.env.SECRET) {
  backupAuthFile();

  fs.mkdirSync(authDirPath, {recursive: true});
  fs.writeFileSync(authFilePath, contents, {flag: "w+"});
}

function restoreAuthFile() {
  if (typeof existingAuthFileContents !== "undefined") {
    fs.writeFileSync(authFilePath, existingAuthFileContents, {flag: "w+"});
  }
}

function backupAuthFile() {
  if (fs.existsSync(authFilePath)) {
    existingAuthFileContents = fs.readFileSync(authFilePath);
  }
}

let client;

describe("using the global authorization in the authfile when the environment variable is not defined", () => {
  beforeEach(() => {
    replaceAuthFile();
    client = Proc.connect();
  });

  afterEach(() => {
    restoreAuthFile();
  });

  test("it uses the proc auth file", async () => {
    expect(await client.core.echo.call(123)).toEqual(123);
  });
});

describe("picking a global authorization when the authfile exists and the environment variable is defined", () => {
  beforeEach(() => {
    process.env.PROC_AUTH = process.env.SECRET;
    replaceAuthFile("invalid");
    client = Proc.connect();
  });

  afterEach(() => {
    restoreAuthFile();
    process.env.PROC_AUTH = undefined;
  });

  test("prefers the environment variable", async () => {
    expect(await client.core.echo.call(123)).toEqual(123);
  });
});

describe("connecting when no global authorization is defined", () => {
  beforeEach(() => {
    process.env.PROC_AUTH = undefined;
    removeAuthFile();
  });

  afterEach(() => {
    restoreAuthFile();
  });

  test("fails to connect", async () => {
    await expect(() => Proc.connect().call("core.ping")).rejects.toThrowError(Unauthorized);
    await expect(() => Proc.connect().call("core.ping")).rejects.toThrowError("authorization is invalid");
  });
});
