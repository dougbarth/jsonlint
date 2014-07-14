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

  it 'should fail with a path that does not exist' do
    jsonlint '/does/not/exist'
    assert_failing_with('no such file')
  end

  it 'should fail with a path that is unreadable' do
    run_simple('mkdir -p tmp')
    run_simple('touch tmp/unreadable_file.json')
    run_simple('chmod -r tmp/unreadable_file.json')

    jsonlint 'tmp/unreadable_file.json'
    assert_failing_with('Permission denied')
  end

  it 'should be able to lint good JSON from STDIN' do
    run_interactive "#{jsonlint_bin} -"
    pipe_in_file(spec_data('valid.json')) and close_input
    assert_success(true)
  end

  it 'should be able to lint bad JSON from STDIN' do
    run_interactive "#{jsonlint_bin} -"
    pipe_in_file(spec_data('missing_comma.json')) and close_input
    assert_success(false)
  end
end
