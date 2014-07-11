require 'trollop'

module JsonLint
  class CLI
    def initialize(argv, stdin = STDIN, stdout = STDOUT, stderr = STDERR, kernel = Kernel)
      @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
    end

    def execute!
      parse_options

      files_to_check = @argv

      Trollop::die 'nead at least one JSON file to check' if files_to_check.empty?

      linter = JsonLint::Linter.new
      begin
        linter.check_all(files_to_check)
      rescue JsonLint::FileNotFoundError => e
        @stderr.puts e.message
        exit(1)
      end

      if linter.has_errors?
        linter.display_errors
        @kernel.exit(1)
      end
    end

    private

    def parse_options
      @opts = Trollop::options(@argv) do
        banner 'Usage: jsonlint [options] file1.json [file2.json ...]'
        version(JsonLint::VERSION)

        banner ''
        banner 'Options:'
      end
    end

    def opts
      @opts
    end
  end
end
