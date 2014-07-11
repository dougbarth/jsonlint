# jsonlint

jsonlint checks your JSON files for syntax errors or silly mistakes. Currently it checks for:

 * Valid JSON syntax
 * Overlapping key definitions in JSON files, where the last definition would win

## Installation

Add this line to your application's Gemfile:

    gem 'jsonlint'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jsonlint

## CLI Usage

You can run jsonlint against a set of files in the command line. Any errors will be printed and the process will exit with a non-zero exit code.

```
$ jsonlint spec/data/*
spec/data/deep_overlap.json
  The same key is defined twice: foo.bar
spec/data/missing_brace.json
  Hash/Object not terminated at line 5, column 2 [sparse.c:782]
spec/data/missing_comma.json
  expected comma, not a string at line 3, column 8 [sparse.c:386]
spec/data/overlapping_keys.json
  The same key is defined twice: foo
```

## Rake task

You can integrate jsonlint into your build process by adding a Rake task to your project

```ruby
require 'jsonlint/rake_task'
JsonLint::RakeTask.new do |t|
  t.paths = %w(
    spec/**/*.json
  )
end
```

Then run the rake task.

```
$ rake jsonlint
spec/data/deep_overlap.json
  The same key is defined twice: foo.bar
spec/data/missing_brace.json
  Hash/Object not terminated at line 5, column 2 [sparse.c:782]
spec/data/missing_comma.json
  expected comma, not a string at line 3, column 8 [sparse.c:386]
spec/data/overlapping_keys.json
  The same key is defined twice: foo
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/jsonlint/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
