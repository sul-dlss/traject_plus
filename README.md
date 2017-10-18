# TrajectPlus

TrajectPlus is a number of useful additions to [Traject](https://github.com/traject/traject)

## Features

### New readers:
#### TrajectPlus::JsonReader
```ruby
provide 'reader_class_name', 'TrajectPlus::JsonReader'
to_field 'title', extract_json('$.label')
```

#### TrajectPlus::CSVReader
```ruby
provide 'reader_class_name', 'TrajectPlus::CSVReader'
to_field 'title', column('Record Title')
```
#### TrajectPlus::XMLReader
```ruby
provide 'reader_class_name', 'TrajectPlus::XMLReader'
to_field 'title', extract_xml('/*/mods:language/mods:scriptTerm',
                              { 'mods' => 'http://www.loc.gov/mods/v3' })
```

There are also XML macros for specific formats (MODS, TEI, FGCD):

For example:
```ruby
to_field 'title', extract_mods('/*/mods:language/mods:scriptTerm')
to_field 'cho_description', extract_tei("/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:summary")
extract_fgdc('/*/idinfo/citation/citeinfo/geoform')
```

### New macros:
* transform_values
* first
* conditional
* from_settings
* match
* format
* translation_map
* other string methods: 'split', 'concat', 'prepend', 'gsub', 'encode', 'insert', 'strip', 'upcase', 'downcase', 'capitalize'

These can be applied to any extract function:

```ruby
to_field 'title', extract_xml('title', gsub: ['|', ' - '])
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'traject_plus'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install traject_plus

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/traject_plus. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the TrajectPlus project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/traject_plus/blob/master/CODE_OF_CONDUCT.md).
