require 'trollop'

module JsonLint
  class CLI
    def initialize(argv, stdin = STDIN, stdout = STDOUT, stderr = STDERR, kernel = Kernel)
      @argv = argv
      @stdin = stdin
      @stdout = stdout
      @stderr = stderr
      @kernel = kernel
    end

    def execute!
      parse_options

      files_to_check = @argv

      Trollop.die 'need at least one JSON file to check' if files_to_check.empty?

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
      rescue StandardError => e
        @stderr.puts e.message
        exit(1)
      end

      return unless linter.errors?
      linter.display_errors
      @kernel.exit(1)
    end

    private

    def parse_options
      @opts = Trollop.options(@argv) do
        banner 'Usage: jsonlint [options] file1.json [file2.json ...]'
        version(JsonLint::VERSION)
        banner ''
        banner 'Options:'
      end
    end
  end
end
