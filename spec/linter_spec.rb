require 'spec_helper'
require 'jsonlint/linter'

describe 'JsonLint::Linter' do
  let(:linter) { JsonLint::Linter.new }

  it 'should throw an exception if given a bogus path' do
    expect { linter.check('/does/not/exist') }.to raise_error(JsonLint::FileNotFoundError)
  end

  it 'should be happy with a valid JSON file' do
    expect(linter.check(spec_data('valid.json'))).to be(true)
    expect(linter.check(spec_data('valid_array_of_objects.json'))).to be(true)
    expect(linter.check(spec_data('valid_array_of_arrays.json'))).to be(true)
    expect(linter.errors_count).to eq(0)
  end

  it 'should be unhappy with an invalid JSON file' do
    expect(linter.check(spec_data('missing_comma.json'))).to be(false)
    expect(linter.errors_count).to eq(1)
  end

  it 'should be unhappy with JSON that has overlapping keys' do
    expect(linter.check(spec_data('overlapping_keys.json'))).to be(false)
    expect(linter.check(spec_data('deep_overlap.json'))).to be(false)
  end

  it 'should be able to check an IO stream' do
    valid_stream = File.open(spec_data('valid.json'))
    expect(linter.check_stream(valid_stream)).to be(true)

    invalid_stream = File.open(spec_data('missing_comma.json'))
    expect(linter.check_stream(invalid_stream)).to be(false)
  end

  it 'should be unhappy with an empty JSON file' do
    expect(linter.check(spec_data('empty_file.json'))).to be(false)
  end

  it 'should be unhapy with a JSON file full of spaces' do
    expect(linter.check(spec_data('lots_of_spaces.json'))).to be(false)
  end

  it 'should not deserialise objects' do
    expect(linter.check(spec_data('serialised.json'))).to be(true)
  end
end
