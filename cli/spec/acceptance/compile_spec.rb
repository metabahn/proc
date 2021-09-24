# frozen_string_literal: true

RSpec.describe "calling the compile command" do
  it "compiles the given file" do
    expect(stdout("compile procs/exec/foo.rb")).to eq("[[\"{}\",[\">>\",[\"%%\",\"foo\"]],[\"()\",\"core.echo\",[\">>\",[\"%%\",\"foo\"]]],[\"()\",\"type.string.reverse\"],[\"()\",\"type.string.upcase\"]]]")
  end

  it "exits successfully" do
    expect(status("compile procs/exec/foo.rb").success?).to eq(true)
  end

  describe "passing an unknown file" do
    it "prints the error" do
      expect(stderr("compile fail.rb")).to eq("stat fail.rb: no such file or directory")
    end

    it "does not exit successfully" do
      expect(status("compile fail.rb").success?).to eq(false)
    end
  end

  describe "not passing a file" do
    it "prints help" do
      expect(stderr("compile")).to eq(help(:compile))
    end

    it "exits unsuccessfully" do
      expect(status("compile").success?).to eq(false)
    end
  end

  describe "-help flag" do
    it "prints help" do
      expect(stdout("-help compile")).to eq(help(:compile))
    end

    it "exits successfully" do
      expect(status("-help compile").success?).to eq(true)
    end
  end

  describe "unknown flag" do
    it "prints help" do
      expect(stderr("compile -foo")).to eq("flag provided but not defined: -foo\n\n" + help(:compile))
    end

    it "does not exit successfully" do
      expect(status("compile -foo").success?).to eq(false)
    end
  end
end
