# frozen_string_literal: true

RSpec.describe "calling the run command" do
  it "run the given file" do
    expect(stdout("run procs/foo.rb")).to eq("OOF")
  end

  it "exits successfully" do
    expect(status("run procs/foo.rb").success?).to eq(true)
  end

  describe "passing an unknown file" do
    it "prints the error" do
      expect(stderr("run fail.rb")).to eq("stat fail.rb: no such file or directory")
    end

    it "does not exit successfully" do
      expect(status("run fail.rb").success?).to eq(false)
    end
  end

  describe "not passing a file" do
    it "prints help" do
      expect(stderr("run")).to eq(help(:run))
    end

    it "exits unsuccessfully" do
      expect(status("run").success?).to eq(false)
    end
  end

  describe "-json flag" do
    it "returns json" do
      expect(stdout("run -json procs/foo.rb")).to eq("\"OOF\"")
    end
  end

  describe "-help flag" do
    it "prints help" do
      expect(stdout("-help run")).to eq(help(:run))
    end

    it "exits successfully" do
      expect(status("-help run").success?).to eq(true)
    end
  end

  describe "unknown flag" do
    it "prints help" do
      expect(stderr("run -foo")).to eq("flag provided but not defined: -foo\n\n" + help(:run))
    end

    it "does not exit successfully" do
      expect(status("run -foo").success?).to eq(false)
    end
  end
end
