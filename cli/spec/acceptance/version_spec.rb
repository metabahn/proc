# frozen_string_literal: true

RSpec.describe "calling the version command" do
  it "prints the version" do
    expect(stdout("version")).to eq("Proc CLI v#{version}")
  end

  it "exits successfully" do
    expect(status("version").success?).to eq(true)
  end

  describe "-help flag" do
    it "prints help" do
      expect(stdout("-help version")).to eq(help(:version))
    end

    it "exits successfully" do
      expect(status("-help version").success?).to eq(true)
    end
  end

  describe "unknown flag" do
    it "prints help" do
      expect(stderr("version -foo")).to eq("flag provided but not defined: -foo\n\n" + help(:version))
    end

    it "does not exit successfully" do
      expect(status("version -foo").success?).to eq(false)
    end
  end
end
