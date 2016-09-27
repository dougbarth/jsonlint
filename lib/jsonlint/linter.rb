require 'oj'
require 'set'

require 'jsonlint/errors'

module JsonLint
  class Linter
    attr_reader :errors

    def initialize
      @errors = {}
    end

    def check_all(*files_to_check)
      files_to_check.flatten.each { |f| check(f) }
    end

    def check(path)
      fail FileNotFoundError, "#{path}: no such file" unless File.exist?(path)

      valid = false
      File.open(path, 'r') do |f|
        error_array = []
        valid = check_data(f.read, error_array)
        errors[path] = error_array unless error_array.empty?
      end

      valid
    end

    def check_stream(io_stream)
      json_data = io_stream.read
      error_array = []

      valid = check_data(json_data, error_array)
      errors[''] = error_array unless error_array.empty?

      valid
    end

    def errors?
      !errors.empty?
    end

    # Return the number of lint errors found
    def errors_count
      errors.length
    end

    def display_errors
      errors.each do |path, errors|
        puts path
        errors.each do |err|
          puts "  #{err}"
        end
      end
    end

    private

    def check_data(json_data, errors_array)
      valid = check_not_empty?(json_data, errors_array)
      valid &&= check_syntax_valid?(json_data, errors_array)
      valid &&= check_overlapping_keys?(json_data, errors_array)

      valid
    end

    def check_not_empty?(json_data, errors_array)
      if json_data.empty?
        errors_array << 'The JSON should not be an empty string'
        false
      elsif json_data.strip.empty?
        errors_array << 'The JSON should not just be spaces'
        false
      else
        true
      end
    end

    def check_syntax_valid?(json_data, errors_array)
      Oj.load(json_data, nilnil: false)
      true
    rescue Oj::ParseError => e
      errors_array << e.message
      false
    end

    class KeyOverlapDetector < Oj::Saj
      attr_reader :overlapping_keys

      def initialize
        @seen_keys = Set.new
        @key_components = []
        @overlapping_keys = Set.new

        @complex_type = []
        @array_positions = []
      end

      def hash_start(key)
        JsonLint.logger.debug { "hash_start: #{key.inspect}" }

        case @complex_type.last
        when :hash
          @key_components.push(key)
        when :array
          @key_components.push(@array_positions.last)
          @array_positions[-1] += 1
        end

        @complex_type.push(:hash)
        check_for_overlap!
      end

      def hash_end(key)
        JsonLint.logger.debug { "hash_end: #{key.inspect}" }
        @key_components.pop
        @complex_type.pop
      end

      def array_start(key)
        JsonLint.logger.debug { "array_start: #{key.inspect}" }

        case @complex_type.last
        when :hash
          @key_components.push(key)
        when :array
          @key_components.push(@array_positions.last)
          @array_positions[-1] += 1
        end

        @complex_type.push(:array)
        @array_positions.push(0)
        check_for_overlap!
      end

      def array_end(key)
        JsonLint.logger.debug { "array_end: #{key.inspect}" }
        @key_components.pop
        @complex_type.pop
        @array_positions.pop
      end

      def add_value(value, key)
        JsonLint.logger.debug { "add_value: #{value.inspect}, #{key.inspect}" }
        case @complex_type.last
        when :hash
          @key_components.push(key)
          check_for_overlap!
          @key_components.pop
        when :array
          @key_components.push(@array_positions.last)
          check_for_overlap!
          @array_positions[-1] += 1
          @key_components.pop
        end
      end

      def error(message, line, column)
        JsonLint.logger.debug { "error: #{message.inspect}, #{line.inspect}, #{column.inspect}" }
      end

      private

      def check_for_overlap!
        full_key = @key_components.dup
        JsonLint.logger.debug { "Checking #{full_key.join('.')} for overlap" }

        return if @seen_keys.add?(full_key)
        JsonLint.logger.debug { "Overlapping key #{full_key.join('.')}" }
        @overlapping_keys << full_key
      end
    end

    def check_overlapping_keys?(json_data, errors_array)
      overlap_detector = KeyOverlapDetector.new
      Oj.saj_parse(overlap_detector, StringIO.new(json_data))

      overlap_detector.overlapping_keys.each do |key|
        errors_array << "The same key is defined more than once: #{key.join('.')}"
      end

      !!overlap_detector.overlapping_keys.empty?
    end
  end
end
