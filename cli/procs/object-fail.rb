exec {
  core.echo("started")
}

proc(name: "deployed") {
  core.echo
    .| type.string.reverse
    .| type.string.upcase
}

proc {
  core.echo
    .| type.string.reverse
    .| type.string.upcase
}

exec {
  core.echo("finished")
}
