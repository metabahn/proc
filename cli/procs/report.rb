exec {
  bucket = type.array.append(["analytics"], value: :environment)
  .| type.array.join(separator: ":")

  bucket = bucket.with(environment: "production")

  keyv.scan(prefix: Time.now.strftime("%Y-%m-%d"), bucket: bucket)
  .| enum.map {
    keyv.get(bucket: bucket)
  }
}
