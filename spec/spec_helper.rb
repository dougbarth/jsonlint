require 'rspec'

module SpecHelpers
  def spec_data(data_path)
    File.expand_path(File.join('spec/data', data_path))
  end
end

RSpec.configure do |config|
  config.include SpecHelpers
end
