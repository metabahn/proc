# frozen_string_literal: true

require "fileutils"

RSpec.describe "calling the login command" do
  describe "passing authorization through an environment variable" do
    it "writes the auth file" do
      stdout("login", env: {"PROC_AUTH" => "12321"})

      expect(dot_proc_path.join("auth").read).to eq("12321")
    end

    it "does not output" do
      expect(stdout("login", env: {"PROC_AUTH" => "12321"})).to eq("")
    end

    it "exits successfully" do
      expect(status("login", env: {"PROC_AUTH" => "12321"}).success?).to eq(true)
    end
  end

  describe "passing authorization through the -auth flag" do
    it "writes the auth file" do
      stdout("-auth foobar login")

      expect(dot_proc_path.join("auth").read).to eq("foobar")
    end

    it "does not output" do
      expect(stdout("-auth foobar login")).to eq("")
    end

    it "exits successfully" do
      expect(status("-auth foobar login").success?).to eq(true)
    end
  end

  describe "preferring -auth flag to the environment variable" do
    it "writes the -auth flag value to the auth file" do
      stdout("-auth foobar login", env: {"PROC_AUTH" => "12321"})

      expect(dot_proc_path.join("auth").read).to eq("foobar")
    end
  end

  context "~/.proc exists" do
    before do
      FileUtils.mkdir_p(dot_proc_path)
    end

    it "writes the auth file" do
      stdout("login", env: {"PROC_AUTH" => "12321"})

      expect(dot_proc_path.join("auth").read).to eq("12321")
    end
  end

  context "~/.proc/auth exists" do
    before do
      FileUtils.mkdir_p(dot_proc_path)

      dot_proc_path.join("auth").open("w+") do |file|
        file.write("12321")
      end
    end

    it "overwrites the auth file" do
      stdout("login", env: {"PROC_AUTH" => "foobar"})

      expect(dot_proc_path.join("auth").read).to eq("foobar")
    end
  end

  describe "-help flag" do
    it "prints help" do
      expect(stdout("-help login")).to eq(help(:login))
    end

    it "exits successfully" do
      expect(status("-help login").success?).to eq(true)
    end
  end

  describe "unknown flag" do
    it "prints help" do
      expect(stderr("login -foo")).to eq("flag provided but not defined: -foo\n\n" + help(:login))
    end

    it "does not exit successfully" do
      expect(status("login -foo").success?).to eq(false)
    end
  end
end
