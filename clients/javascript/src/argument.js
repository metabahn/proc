import {default as serialize} from "./serialize";

export default class {
  constructor(name, options = {}) {
    this.name = name;
    this.options = options;
  }

  serialize() {
    const serializedOptions = {};
    for (const key in this.options) {
      serializedOptions[key] = serialize(this.options[key]);
    }

    return ["@@", this.name, serializedOptions];
  }
}
