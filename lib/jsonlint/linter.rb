require 'oj'

module Jsonlint
  class Linter
    def check(path)
      Oj.load_file(path)
      true
    rescue SyntaxError
      false
    end
  end
end
