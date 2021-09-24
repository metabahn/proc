exec {
  type.array.build([])
  .| type.array.append(value: :foo)
  .| type.array.append(value: :bar)
}
