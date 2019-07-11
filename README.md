[![Build Status](https://travis-ci.org/hasghari/table_saw.svg?branch=master)](https://travis-ci.org/hasghari/table_saw)
[![Maintainability](https://api.codeclimate.com/v1/badges/abd5b5451c764d3249f1/maintainability)](https://codeclimate.com/github/hasghari/table_saw/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/abd5b5451c764d3249f1/test_coverage)](https://codeclimate.com/github/hasghari/table_saw/test_coverage)

# TableSaw

This gem creates a PSQL dump file (data only) from a Postgres database by only dumping a subset of data defined by a 
manifest file.

It will automatically retrieve the foreign key dependencies of your tables as long as the foreign key constraints are
defined.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'table_saw'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install table_saw

## Usage

```
table-saw dump -m manifest.yml
```

The command above will read your configuration from `manifest.yml` and create a dump file `output.dump`. The database
connection properties can be supplied similar to the `pg_dump` tool provided by Postgres:

```
Usage:
  table-saw dump -m, --manifest=MANIFEST

Options:
  -u, [--url=URL]             # Default value is $DATABASE_URL
  -d, [--dbname=DBNAME]       # Default value is $PGDATABASE
  -h, [--host=HOST]           # Default value is $PGHOST
  -p, [--port=PORT]           # Default value is $PGPORT
  -U, [--user=USER]           # Default value is $PGUSER
      [--password=PASSWORD]   # Default value is $PGPASSWORD
  -m, --manifest=MANIFEST
  -o, [--output=OUTPUT]       # Default value is 'output.dump'
```

The manifest file describes which tables you want to dump from your Postgres database:

```yaml
variables:
  author_id: 24
tables:
  - table: books
    query: "select * from books where author_id = %{author_id}"
```

This will only fetch records from the `books` table where `author_id = 24` and will also fetch the record from the
`authors` table where `id = 24`.

Assuming there is a `chapters` table with a foreign key reference of `book_id` to the `books` table, the above manifest
file will **not** automatically retrieve those records. If `chapters` records are also desired, there a couple ways to 
accomplish this:

```yaml
variables:
  author_id: 24
tables:
  - table: books
    query: "select * from books where author_id = %{author_id}"
has_many:
  books:
    - chapters
```

or

```yaml
variables:
  author_id: 24
tables:
  - table: chapters
    query: "select * from chapters inner join books on books.id = chapters.book_id where books.author_id = %{author_id}"
```

The output of the 2 manifest files above are exactly the same. The dump file will contain all the relevant records from
the `authors`, `books` and `chapters` tables.

Once your dump file has been created, you can import the data using `psql`:

```bash
table-saw dump -m manifest.yml -o chapters.dump
psql -h localhost -U postgres -d library < chapters.dump
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can 
also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the 
version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, 
push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hasghari/table_saw. This project is intended 
to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the 
[Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TableSaw project’s codebases, issue trackers, chat rooms and mailing lists is expected to 
follow the [code of conduct](https://github.com/[USERNAME]/table_saw/blob/master/CODE_OF_CONDUCT.md).
