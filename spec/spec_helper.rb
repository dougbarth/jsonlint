require 'rspec'

require 'aruba'
require 'aruba/rspec'

require 'jsonlint'

module SpecHelpers
  def spec_data(data_path)
    File.expand_path(File.join('spec/data', data_path))
  end
end

module CliSpecHelpers
  def jsonlint(args = nil)
    run_simple("#{jsonlint_bin} #{args}", fail_on_error: false)
  end

  def jsonlint_bin
    File.expand_path('../../bin/jsonlint', __FILE__)
  end
end

RSpec.configure do |config|
  config.include SpecHelpers
  config.include CliSpecHelpers
  config.include Aruba::Api

  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
