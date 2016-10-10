require 'rake'
require 'rake/tasklib'

require 'jsonlint'

module JsonLint
  class RakeTask < Rake::TaskLib
    attr_accessor :name
    attr_accessor :paths
    attr_accessor :ignore_paths

    def initialize(name = :jsonlint)
      @name = name

      yield self if block_given?

      define_task
    end

    private

    def define_task
      desc 'Run jsonlint' unless ::Rake.application.last_description

      task(name) do
        puts 'Running JsonLint...'

        files_to_check = Rake::FileList.new(paths)
        files_to_ignore = Rake::FileList.new(ignore_paths)

        files_to_check = files_to_check - files_to_ignore

        puts "Checking #{files_to_check.flatten.length} files"

        linter = ::JsonLint::Linter.new
        linter.check_all(files_to_check)

        if linter.errors?
          linter.display_errors
          puts "JSON lint found #{linter.errors_count} errors"
          abort('JsonLint failed!')
        else
          puts 'JsonLint found no errors'
        end
      end
    end
  end
end
