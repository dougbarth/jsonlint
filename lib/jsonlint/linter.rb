require 'oj'
require 'set'

require 'jsonlint/errors'

module Jsonlint
  class Linter
    attr_reader :errors

    def initialize
      @errors = Hash.new {|h,k| h[k] = [] }
    end

    def check_all(*files_to_check)
      files_to_check.flatten.each {|f| check(f) }
    end

    def check(path)
      raise FileNotFoundError, "#{path} does not exist" unless File.exist?(path)

      check_syntax_valid(path) && check_overlapping_keys(path)
    end

    def has_errors?
      ! errors.empty?
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

    def check_syntax_valid(path)
      Oj.load_file(path, nilnil: false)
      true
    rescue Oj::ParseError => e
      errors[path] << e.message
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
        Jsonlint.logger.debug { "hash_start: #{key.inspect}" }

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
        Jsonlint.logger.debug { "hash_end: #{key.inspect}" }
        @key_components.pop
        @complex_type.pop
      end

      def array_start(key)
        Jsonlint.logger.debug { "array_start: #{key.inspect}" }

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
        Jsonlint.logger.debug { "array_end: #{key.inspect}" }
        @key_components.pop
        @complex_type.pop
        @array_positions.pop
      end

      def add_value(value, key)
        Jsonlint.logger.debug { "add_value: #{value.inspect}, #{key.inspect}" }
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
        Jsonlint.logger.debug { "error: #{message.inspect}, #{line.inspect}, #{column.inspect}" }
      end

      private
      def check_for_overlap!
        full_key = @key_components.dup
        Jsonlint.logger.debug { "Checking #{full_key.join('.')} for overlap" }

        unless @seen_keys.add?(full_key)
          Jsonlint.logger.debug { "Overlapping key #{full_key.join('.')}" }
          @overlapping_keys << full_key
        end
      end
    end

    def check_overlapping_keys(path)
      overlap_detector = KeyOverlapDetector.new
      File.open(path, 'r') do |f|
        Oj.saj_parse(overlap_detector, f)
      end

      overlap_detector.overlapping_keys.each do |key|
        errors[path] << "The same key is defined twice: #{key.join('.')}"
      end

      !! overlap_detector.overlapping_keys.empty?
    end
  end
end
