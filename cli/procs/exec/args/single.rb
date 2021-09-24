exec {
  core.echo(:foo)
    .| type.string.reverse
    .| type.string.upcase
}
