module Jsonlint
  class CLI
    def initialize(argv, stdin = STDIN, stdout = STDOUT, stderr = STDERR, kernel = Kernel)
      @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
    end

    def execute!
      files_to_check = @argv

      linter = Jsonlint::Linter.new
      files_to_check.each do |file|
        linter.check(file)
      end

      unless linter.errors.empty?
        linter.errors.each do |path, errors|
          puts path
          errors.each do |err|
            puts "  #{err}"
          end
        end

        @kernel.exit(1)
      end
    end
  end
end
