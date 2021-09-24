exec {
  core.echo("started")
}

proc(name: "deployed1") {
  core.echo
    .| type.string.reverse
    .| type.string.upcase
}

proc(name: "deployed2") {
  core.echo
    .| type.string.reverse
    .| type.string.upcase
}

exec {
  core.echo("finished")
}
