require 'spec_helper'
require 'jsonlint/linter'

describe 'Jsonlint::Linter' do
  let(:linter) { Jsonlint::Linter.new }

  it 'should be happy with a valid JSON file' do
    expect(linter.check(spec_data('valid.json'))).to be(true)
  end

  it 'should be unhappy with an invalid JSON file' do
    expect(linter.check(spec_data('missing_comma.json'))).to be(false)
  end

  it 'should throw an exception if given a bogus path' do
    expect { linter.check('/does/not/exist') }.to raise_error
  end
end
