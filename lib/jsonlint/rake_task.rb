require 'rake'
require 'rake/tasklib'

require 'jsonlint'

module JsonLint
  class RakeTask < Rake::TaskLib
    attr_accessor :name
    attr_accessor :paths

    def initialize(name = :jsonlint)
      @name = name

      yield self if block_given?

      define_task
    end

    private

    def define_task
      desc 'Run jsonlint' unless ::Rake.application.last_comment

      task(self.name) do
        files_to_check = Rake::FileList.new(self.paths)

        linter = ::JsonLint::Linter.new
        linter.check_all(files_to_check)

        if linter.has_errors?
          linter.display_errors
          abort('JSON lint found')
        end
      end
    end
  end
end
