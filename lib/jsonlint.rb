require 'logger'

require 'jsonlint/version'
require 'jsonlint/linter'

module JsonLint
  # Your code goes here...
  def self.logger
    @logger ||= Logger.new(STDOUT).tap do |l|
      l.level = Logger::INFO
    end
  end
end
