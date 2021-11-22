# frozen_string_literal: true

RSpec.describe "handling return types from exec within a deploy" do
  it "handles strings" do
    expect(stdout("deploy procs/deploy/exec/types/string.rb")).to eq(<<~OUTPUT.strip)
      [exec]: ok
        foo

      [proc] type.string: ok
        proc.run/lib/type.string:dev
    OUTPUT
  end

  it "handles integers" do
    expect(stdout("deploy procs/deploy/exec/types/integer.rb")).to eq(<<~OUTPUT.strip)
      [exec]: ok
        42

      [proc] type.integer: ok
        proc.run/lib/type.integer:dev
    OUTPUT
  end

  it "handles decimals" do
    expect(stdout("deploy procs/deploy/exec/types/decimal.rb")).to eq(<<~OUTPUT.strip)
      [exec]: ok
        42.42

      [proc] type.decimal: ok
        proc.run/lib/type.decimal:dev
    OUTPUT
  end

  it "handles booleans" do
    expect(stdout("deploy procs/deploy/exec/types/boolean.rb")).to eq(<<~OUTPUT.strip)
      [exec]: ok
        true

      [proc] type.boolean: ok
        proc.run/lib/type.boolean:dev
    OUTPUT
  end

  it "handles hashes" do
    expect(stdout("deploy procs/deploy/exec/types/hash.rb")).to eq(<<~OUTPUT.strip)
      [exec]: ok
        {"foo":"bar"}

      [proc] type.hash: ok
        proc.run/lib/type.hash:dev
    OUTPUT
  end

  it "handles arrays" do
    expect(stdout("deploy procs/deploy/exec/types/array.rb")).to eq(<<~OUTPUT.strip)
      [exec]: ok
        ["foo"]

      [proc] type.array: ok
        proc.run/lib/type.array:dev
    OUTPUT
  end
end
