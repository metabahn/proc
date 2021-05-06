export default function(value) {
  if (value && typeof value.serialize !== "undefined") {
    return value.serialize();
  } else {
    return ["%%", value];
  }
};
