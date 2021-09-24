proc(name: "deployed") {
  core.echo
    .| type.string.reverse
    .| type.string.upcase
}
