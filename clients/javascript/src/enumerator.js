export default class {
  constructor(values, callback, fetch) {
    this.values = values;
    this.fetch = fetch;

    if (callback) {
      return this.each(callback);
    }
  }

  async* [Symbol.asyncIterator]() {
    for (let value of this.values) {
      yield value;
    }

    if (this.fetch) {
      yield* await this.fetch();
    }
  }

  // [public] Calls the given function once for each value.
  //
  async each(callback) {
    for await (const value of this) {
      const result = callback(value);

      if (result === false) {
        return;
      }
    }
  }

  // [public] Returns an array of values.
  //
  async toArray() {
    const array = [];

    for await(const value of this) {
      array.push(value);
    }

    return array;
  }
}
