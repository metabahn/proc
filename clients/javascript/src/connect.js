import {default as Client} from "./client";

// [public] Convenience method for connecting a new client.
//
export default function(authorization, options) {
  return Client.connect(authorization, options);
};
