require 'optimist'

module JsonLint
  class CLI
    def initialize(argv, stdin = STDIN, stdout = STDOUT, stderr = STDERR, kernel = Kernel)
      @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
    end

    def execute!
      parse_options

      files_to_check = @argv

      Optimist::die 'need at least one JSON file to check' if files_to_check.empty?

      linter = JsonLint::Linter.new
      begin
        if files_to_check == ['-']
          linter.check_stream(STDIN)
        else
          linter.check_all(files_to_check)
        end
      rescue JsonLint::FileNotFoundError => e
        @stderr.puts e.message
        exit(1)
      rescue => e
        @stderr.puts e.message
        exit(1)
      end

      return unless linter.errors?
      linter.display_errors
      @kernel.exit(1)
    end

    private

    def parse_options
      @opts = Optimist.options(@argv) do
        banner 'Usage: jsonlint [options] file1.json [file2.json ...]'
        version(JsonLint::VERSION)
        banner ''
        banner 'Options:'
      end
    end
  end
end
