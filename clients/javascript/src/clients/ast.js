import {default as Client} from "../client";

export default class extends Client {
  async process(proc, body, input, args, callback) {
    if (proc !== "core.exec") {
      body = [["$$", "proc", ["{}", ["()", proc].concat(body)]]];
    }

    return body;
  }
}
