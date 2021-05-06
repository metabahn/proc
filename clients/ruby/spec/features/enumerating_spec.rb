# frozen_string_literal: true

require_relative "support/context/acceptance"

RSpec.describe "ruby client api: enumerating" do
  include_context "acceptance"

  let(:key) {
    SecureRandom.hex(4)
  }

  let(:bucket) {
    SecureRandom.hex(4)
  }

  let(:keys) {
    []
  }

  before do
    10.times do |index|
      keys << index.to_s

      client["keyv.set"].call(bucket: bucket, key: index, value: index)
    end
  end

  it "enumerates through each" do
    scanned = []

    client["keyv.scan"].each(bucket: bucket, count: 3) do |key|
      scanned << key
    end

    expect(scanned).to eq(keys)
  end

  it "returns an enumerator from call" do
    expect(client["keyv.scan"].call(bucket: bucket, count: 3).to_a).to eq(keys)
  end

  it "returns the enumerator from each" do
    expect(client["keyv.scan"].each(bucket: bucket, count: 3).to_a).to eq(keys)
  end
end
