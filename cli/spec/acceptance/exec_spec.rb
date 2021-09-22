# frozen_string_literal: true

RSpec.describe "calling the exec command" do
  it "execs the given file" do
    expect(stdout("exec procs/foo.rb")).to eq("OOF")
  end

  it "exits successfully" do
    expect(status("exec procs/foo.rb").success?).to eq(true)
  end

  describe "passing an unknown file" do
    it "prints the error" do
      expect(stderr("exec fail.rb")).to eq("stat fail.rb: no such file or directory")
    end

    it "does not exit successfully" do
      expect(status("exec fail.rb").success?).to eq(false)
    end
  end

  describe "not passing a file" do
    it "prints help" do
      expect(stderr("exec")).to eq(help(:exec))
    end

    it "exits unsuccessfully" do
      expect(status("exec").success?).to eq(false)
    end
  end

  describe "-json flag" do
    it "returns json" do
      expect(stdout("exec -json procs/foo.rb")).to eq("\"OOF\"")
    end
  end

  describe "-help flag" do
    it "prints help" do
      expect(stdout("-help exec")).to eq(help(:exec))
    end

    it "exits successfully" do
      expect(status("-help exec").success?).to eq(true)
    end
  end

  describe "unknown flag" do
    it "prints help" do
      expect(stderr("exec -foo")).to eq("flag provided but not defined: -foo\n\n" + help(:exec))
    end

    it "does not exit successfully" do
      expect(status("exec -foo").success?).to eq(false)
    end
  end
end
