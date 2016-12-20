require 'rake'
require 'rake/tasklib'

require 'jsonlint'

module JsonLint
  class RakeTask < Rake::TaskLib
    attr_accessor :name
    attr_accessor :paths
    attr_accessor :exclude_paths
    attr_accessor :fail_on_error
    attr_accessor :log_level

    def initialize(name = :jsonlint)
      @name = name
      @exclude_paths = []
      @fail_on_error = true

      yield self if block_given?

      define_task
    end

    private

    def define_task
      desc 'Run jsonlint' unless ::Rake.application.last_description

      task(name) do
        puts 'Running JsonLint...'

        JsonLint.logger.level = Logger.const_get(log_level) if log_level

        files_to_check_raw = Rake::FileList.new(paths)
        files_to_exclude = Rake::FileList.new(exclude_paths)
        files_to_check = files_to_check_raw.exclude(files_to_exclude)

        puts "Checking #{files_to_check.flatten.length} files"
        puts "Excluding #{files_to_exclude.flatten.length} files"

        linter = ::JsonLint::Linter.new
        linter.check_all(files_to_check)

        if linter.errors?
          linter.display_errors
          puts "JSON lint found #{linter.errors_count} errors"
          abort('JsonLint failed!') if fail_on_error
        else
          puts 'JsonLint found no errors'
        end
      end
    end
  end
end
