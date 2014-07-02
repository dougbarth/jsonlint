require 'oj'
require 'jsonlint/errors'

module Jsonlint
  class Linter
    def check(path)
      raise FileNotFoundError, "#{path} does not exist" unless File.exist?(path)

      Oj.load_file(path, nilnil: false)
      true
    rescue Oj::ParseError
      false
    end
  end
end
