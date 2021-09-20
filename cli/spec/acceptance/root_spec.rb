# frozen_string_literal: true

RSpec.describe "calling the root executable" do
  it "prints help" do
    expect(stderr).to eq(help)
  end

  it "does not exit successfully" do
    expect(status.success?).to eq(false)
  end

  describe "-help flag" do
    it "prints help" do
      expect(stdout("-help")).to eq(help)
    end

    it "exits successfully" do
      expect(status("-help").success?).to eq(true)
    end
  end

  describe "unknown flag" do
    it "prints help" do
      expect(stderr("-foo")).to eq("flag provided but not defined: -foo\n\n" + help)
    end

    it "does not exit successfully" do
      expect(status("-foo").success?).to eq(false)
    end
  end

  describe "unknown command" do
    it "prints help" do
      expect(stderr("foo")).to eq("unknown command: foo\n\n" + help)
    end

    it "does not exit successfully" do
      expect(status("foo").success?).to eq(false)
    end
  end
end
