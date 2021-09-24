proc(name: :name, release: arg(:release)) {
  core.echo
    .| type.string.reverse
    .| type.string.upcase
}
