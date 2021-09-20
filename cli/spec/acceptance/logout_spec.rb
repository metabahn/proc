# frozen_string_literal: true

require "fileutils"

RSpec.describe "calling the logout command" do
  before do
    FileUtils.mkdir_p(dot_proc_path)

    dot_proc_path.join("auth").open("w+") do |file|
      file.write("testing123")
    end
  end

  it "removes the authorization" do
    expect {
      stdout("logout")
    }.to change {
      dot_proc_path.join("auth").exist?
    }.from(true).to(false)
  end

  it "does not output" do
    expect(stdout("logout")).to eq("")
  end

  it "exits successfully" do
    expect(status("logout").success?).to eq(true)
  end

  context "no local authorization is available" do
    before do
      FileUtils.rm_r(dot_proc_path)
    end

    it "does not output" do
      expect(stdout("logout")).to eq("")
    end

    it "exits successfully" do
      expect(status("logout").success?).to eq(true)
    end
  end

  describe "-help flag" do
    it "prints help" do
      expect(stdout("-help logout")).to eq(help(:logout))
    end

    it "exits successfully" do
      expect(status("-help logout").success?).to eq(true)
    end
  end

  describe "unknown flag" do
    it "prints help" do
      expect(stderr("logout -foo")).to eq("flag provided but not defined: -foo\n\n" + help(:logout))
    end

    it "does not exit successfully" do
      expect(status("logout -foo").success?).to eq(false)
    end
  end
end
