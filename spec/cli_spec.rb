require 'spec_helper'

describe 'jsonlint' do
  it 'should print usage if run with no args' do
    jsonlint
    assert_failing_with('Error')
  end

  it '-h should print usage' do
    jsonlint '-h'
    assert_passing_with('Usage')
  end

  it '--help should print usage' do
    jsonlint '--help'
    assert_passing_with('Usage')
  end

  it '-v should print its version' do
    jsonlint '-v'
    assert_passing_with(JsonLint::VERSION)
  end

  it '--version should print its version' do
    jsonlint '--version'
    assert_passing_with(JsonLint::VERSION)
  end

  it 'should exit successfully with good JSON' do
    jsonlint spec_data('valid.json')
    assert_success(true)
  end

  it 'should fail with bad JSON' do
    jsonlint spec_data('missing_comma.json')
    assert_success(false)
  end
end
