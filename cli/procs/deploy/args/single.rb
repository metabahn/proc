proc(name: :name) {
  core.echo
    .| type.string.reverse
    .| type.string.upcase
}
