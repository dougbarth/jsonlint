module JsonLint
  class CLI
    def initialize(argv, stdin = STDIN, stdout = STDOUT, stderr = STDERR, kernel = Kernel)
      @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
    end

    def execute!
      files_to_check = @argv

      linter = JsonLint::Linter.new
      linter.check_all(files_to_check)

      if linter.has_errors?
        linter.display_errors
        @kernel.exit(1)
      end
    end
  end
end
