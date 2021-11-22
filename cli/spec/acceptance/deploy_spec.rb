# frozen_string_literal: true

RSpec.describe "calling the deploy command" do
  after do
    run("exec procs/deploy/cleanup.rb")
  end

  it "deploys the given file" do
    expect(status("deploy procs/deploy/single.rb").success?).to be(true)

    expect(stdout("exec procs/deploy/single-call.rb")).to eq("321GNITSET")
  end

  it "outputs the expected result" do
    expect(stdout("deploy procs/deploy/single.rb")).to eq(
      <<~OUTPUT.strip
        [proc] deployed: ok
          proc.run/lib/deployed:dev
      OUTPUT
    )
  end

  it "exits successfully" do
    expect(status("deploy procs/deploy/single.rb").success?).to eq(true)
  end

  describe "deploying a file with many types" do
    it "outputs the expected result" do
      expect(stdout("deploy procs/deploy/many.rb")).to eq(
        <<~OUTPUT.strip
          [exec]: ok
            started

          [proc] deployed1: ok
            proc.run/lib/deployed1:dev

          [proc] deployed2: ok
            proc.run/lib/deployed2:dev

          [exec]: ok
            finished
        OUTPUT
      )
    end
  end

  describe "deploying a file that contains no deployable objects" do
    it "outputs the expected result" do
      expect(stdout("deploy procs/deploy/none.rb")).to eq("400 Bad Request: invalid argument `objects' for `core.deploy' (does not have any deployable objects)")
    end
  end

  describe "deploying a file that fails to deploy" do
    it "outputs the expected result" do
      expect(stdout("deploy procs/deploy/fail.rb")).to eq(
        <<~OUTPUT.strip
          [exec]: ok
            started

          [proc] deployed: ok
            proc.run/lib/deployed:dev

          [proc] (undefined): failed
            invalid argument `name' for `proc.deploy' (must contain only alphanumeric characters; `.' and `_' are allowed)
        OUTPUT
      )
    end
  end

  describe "passing an unknown file" do
    it "prints the error" do
      expect(stderr("deploy fail.rb")).to eq("stat fail.rb: no such file or directory")
    end

    it "does not exit successfully" do
      expect(status("deploy fail.rb").success?).to eq(false)
    end
  end

  describe "not passing a file" do
    it "prints help" do
      expect(stderr("deploy")).to eq(help(:deploy))
    end

    it "exits unsuccessfully" do
      expect(status("deploy").success?).to eq(false)
    end
  end

  describe "passing args" do
    it "passes one arg" do
      expect(stdout("deploy -arg name=bar procs/deploy/args/single.rb")).to eq(
        <<~OUTPUT.strip
          [proc] bar: ok
            proc.run/lib/bar:dev
        OUTPUT
      )
    end

    it "passes multiple args" do
      expect(stdout("deploy -arg name=bar -arg production=true procs/deploy/args/many.rb")).to eq(
        <<~OUTPUT.strip
          [proc] bar: ok
            proc.run/lib/bar
        OUTPUT
      )
    end
  end

  describe "-release flag" do
    it "deploys to the release stage" do
      expect(stdout("deploy -release procs/deploy/single.rb")).to eq(
        <<~OUTPUT.strip
          [proc] deployed: ok
            proc.run/lib/deployed
        OUTPUT
      )
    end
  end

  describe "-json flag" do
    it "returns json for successful deploys" do
      expect(stdout("deploy -json procs/deploy/single.rb")).to eq("[{\"status\":\"ok\",\"type\":\"proc\",\"name\":\"deployed\",\"link\":\"proc.run/lib/deployed:dev\"}]")
    end

    it "returns json for unsuccessful deploys" do
      expect(stdout("deploy -json procs/deploy/fail.rb")).to eq("[{\"status\":\"ok\",\"type\":\"exec\",\"output\":\"started\"},{\"status\":\"ok\",\"type\":\"proc\",\"name\":\"deployed\",\"link\":\"proc.run/lib/deployed:dev\"},{\"status\":\"failed\",\"type\":\"proc\",\"name\":null,\"error\":\"invalid argument `name' for `proc.deploy' (must contain only alphanumeric characters; `.' and `_' are allowed)\"}]")
    end

    it "returns json for total failures" do
      expect(stdout("deploy -json procs/deploy/none.rb")).to eq("{\"error\":{\"message\":\"invalid argument `objects' for `core.deploy' (does not have any deployable objects)\"}}")
    end
  end

  describe "-help flag" do
    it "prints help" do
      expect(stdout("-help deploy")).to eq(help(:deploy))
    end

    it "exits successfully" do
      expect(status("-help deploy").success?).to eq(true)
    end
  end

  describe "unknown flag" do
    it "prints help" do
      expect(stderr("deploy -foo")).to eq("flag provided but not defined: -foo\n\n" + help(:deploy))
    end

    it "does not exit successfully" do
      expect(status("deploy -foo").success?).to eq(false)
    end
  end
end
