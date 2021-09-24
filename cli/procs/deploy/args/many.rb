proc(name: :name, release: arg(:production)) {
  core.echo
    .| type.string.reverse
    .| type.string.upcase
}
