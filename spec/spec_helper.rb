require 'rspec'

require 'aruba'
require 'aruba/api'

require 'jsonlint'

module SpecHelpers
  def spec_data(data_path)
    File.expand_path(File.join('spec/data', data_path))
  end
end

module CliSpecHelpers
  def jsonlint(args = nil)
    jsonlint_bin = File.expand_path('../../bin/jsonlint', __FILE__)
    run_simple("#{jsonlint_bin} #{args}", false)
  end
end

RSpec.configure do |config|
  config.include SpecHelpers
  config.include CliSpecHelpers
  config.include Aruba::Api
end
