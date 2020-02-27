# Unused

Unused tracks the usage of all your application's methods during runtime and identifies methods that were never called.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'unused, require: false'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install unused

## Basic Usage

Load and start Unused just before loading your application code. For instance, in a rails app, add the following lines
to `config/environment.rb`
```
require_relative 'application'

# Add these two lines
require_relative "../../unused/lib/unused"
Unused.start

Rails.application.initialize!
```

When the application finishes execution (when the server is stopped in the above example), Unused will report all of the
methods defined in your application and the usage.

## Configuration

### Path
Specifies where the code to track is located on the file system.

```
# default
# The root of the project
Unused.configure do |config|
  config.path = Dir.pwd
end

# Only track classes defined in app/models
Unused.configure do |config|
  config.path = Pathname.new(Dir.pwd).join("app", "models").to_s
end
```

### Reporter
Specifies the method of reporting results
```
# default
# a csv report listing all of the methods, their location, and the number of calls
# can specify output file via output_file configuration
Unused.configure do |config|
  config.reporter = :csv
end

# Report results to stdout
# will only print methods with 0 calls
Unused.configure do |config|
  config.reporter = :stdout
end
```

### Output File
Specifies the output for the csv reporter
```
# default
# output report to unused_methods.csv in the project root
Unused.configure do |config|
  config.output_file = "#{Dir.pwd}/unused_methods.csv" 
end

# output report to a file appened with the day in the temp directory
Unused.configure do |config|
  config.output_file = "#{Dir.pwd}/tmp/unused_methods_#{DateTime.now.strftime("%Y_%m_%d")}.csv" 
end
```

### Report At Exit
Specifies whether or not to automatically report at exit of program.
```
# default
# will automatically report at exit of program
Unused.configure do |config|
  config.report_at_exit = true
end

# do not automatically produce report
# require explicit call to Unused.report
Unused.configure do |config|
  config.report_at_exit = true
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sdfreund10/unused.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
