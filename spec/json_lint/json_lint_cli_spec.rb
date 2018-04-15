require 'spec_helper'

describe JsonLint do
  it 'prints usage if run with no args' do
    jsonlint
    expect(last_command_started).not_to be_successfully_executed
    expect(last_command_started).to have_output(/Error: need at least one JSON file to check./)
  end

  it '-h should print usage' do
    jsonlint '-h'
    expect(last_command_started).to be_successfully_executed
    expect(last_command_started).to have_output(/Usage: jsonlint/)
  end

  it '--help should print usage' do
    jsonlint '--help'
    expect(last_command_started).to be_successfully_executed
    expect(last_command_started).to have_output(/Usage: jsonlint/)
  end

  it '-v should print its version' do
    jsonlint '-v'
    expect(last_command_started).to be_successfully_executed
    expect(last_command_started).to have_output JsonLint::VERSION
  end

  it '--version should print its version' do
    jsonlint '--version'
    expect(last_command_started).to be_successfully_executed
    expect(last_command_started).to have_output JsonLint::VERSION
  end

  it 'exits successfully with good JSON' do
    jsonlint spec_data('valid.json')
    expect(last_command_started).to be_successfully_executed
  end

  it 'fails with bad JSON' do
    jsonlint spec_data('missing_comma.json')
    expect(last_command_started).not_to be_successfully_executed
  end

  it 'fails with a path that does not exist' do
    jsonlint '/does/not/exist'
    expect(last_command_started).not_to be_successfully_executed
    expect(last_command_started).to have_output(/no such file/)
  end

  it 'fails with a path that is unreadable' do
    file = Tempfile.new('unreadable_file.json')
    run_simple("chmod -r #{file.path}")

    jsonlint file.path
    expect(last_command_started).not_to be_successfully_executed
    expect(last_command_started).to have_output(/Permission denied/)
  end

  it 'is able to lint good JSON from STDIN' do
    run "#{jsonlint_bin} -"
    pipe_in_file('../../spec/data/valid.json') && close_input
    expect(last_command_started).to be_successfully_executed
  end

  it 'is able to lint bad JSON from STDIN' do
    run "#{jsonlint_bin} -"
    pipe_in_file('../../spec/data/missing_comma.json') && close_input
    expect(last_command_started).not_to be_successfully_executed
  end
end
