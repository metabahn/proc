# frozen_string_literal: true

RSpec.configure do |config|
  config.before :suite do
    unless system "go build"
      exit false
    end
  end
end
