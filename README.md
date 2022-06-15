![](https://github.com/hasghari/table_saw/workflows/Ruby/badge.svg)
[![Maintainability](https://api.codeclimate.com/v1/badges/abd5b5451c764d3249f1/maintainability)](https://codeclimate.com/github/hasghari/table_saw/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/abd5b5451c764d3249f1/test_coverage)](https://codeclimate.com/github/hasghari/table_saw/test_coverage)

# table-saw

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

### Manifest

The manifest is a YAML file that describes the dataset to be exported to a dump file. At the top level, the manifest 
file supports 4 nodes:

- [variables](#variables)
- [tables](#tables)
- [has_many](#has_many)
- [foreign_keys](#foreign_keys)

The examples that follow assume you have a database set up as follows:
```sql
CREATE TABLE authors (
    id bigint NOT NULL,
    name character varying NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE books (
    id bigint NOT NULL,
    author_id bigint NOT NULL,
    name character varying NOT NULL,
    votes integer DEFAULT 0 NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_author FOREIGN KEY (author_id) REFERENCES authors(id)
);

INSERT INTO authors (id, name) VALUES (1, 'Dan Brown');
INSERT INTO authors (id, name) VALUES (2, 'J. K. Rowling');

INSERT INTO books (id, author_id, name, votes) VALUES (1, 1, 'Angels and Demons', 10);
INSERT INTO books (id, author_id, name, votes) VALUES (2, 1, 'Digital Fortress', 35);
INSERT INTO books (id, author_id, name, votes) VALUES (3, 1, 'The Da Vinci Code', 50);
INSERT INTO books (id, author_id, name, votes) VALUES (4, 2, 'Philosopher''s Stone', 55);
INSERT INTO books (id, author_id, name, votes) VALUES (5, 2, 'Chamber of Secrets', 5);
INSERT INTO books (id, author_id, name, votes) VALUES (6, 2, 'Prisoner of Azkaban', 25);
```

#### variables
Variables allow you parameterize the queries in the manifest. You can use the `%{variable}` substitution pattern in your
query strings:

```yaml
variables:
  author_id: 2
tables:
  - table: books
    query: "select * from books where author_id = %{author_id}"
```

Additionally, you can now use the `%{variable}` substitution pattern in subsequent variables:
```yaml
variables:
  author_id: '1,3,4',
  book_ids: 'select * from books where author_id in (%{author_id})' 
```

Note that only previously assigned variables can be substituted into subsequent variables, attempting to access a variable before it is declared like this:
```yaml
variables:
  author_id: '%{book_ids}',
  book_ids: 'select * from books limit 10'  
```
will result in incorrectly assembled queries (i.e. passing %{book_ids} into the SQL query.)

#### tables
This is where you list the specific tables that you want to export. If you only specify the `table` without providing a 
`query`, then the **entire** table will be exported. However, if you specify a `query`, then only rows matching that 
query will be exported:

```yaml
tables:
  - table: books
    query: "select * from books where author_id = 2"
```

The above manifest will only export rows from the `books` table where `author_id = 2`. In addition, due to the 
foreign key constraint defined from `books(author_id)` to `authors(id)`, table-saw will automatically export the row 
from the `authors` table where `id = 2` in order to preserve referential integrity.

The above manifest can alternatively be written as follows where exactly the same rows would be exported:

```yaml
tables:
  - table: authors
    query: "select * from authors where id = 2"
    has_many:
      - books
```

Notice we have to explicitly list the `has_many` association to the `books` table. Since `authors` does not have a
dependency on `books` to preserve referential integrity, table-saw by design will not export the associated `books`
rows in order to keep the output dump file as small as possible. In other words, if we eliminate the `has_many` node
from the manifest above, table-saw will only export a single author with `id = 2`.

#### has_many
This is where we define which optional associations we want to export for each table:

```yaml
tables:
  - table: authors
    query: "select * from authors where id = 1"
  - table: books
    query: "select * from books where id = 6"
has_many:
  authors:
    - books
```

The above manifest would export the following rows:

* authors:
  - `id = 1` because of the explicit query in the manifest
  - `id = 2` because it is the `author_id` for `books` with `id = 6`

* books:
  - `id = [1, 2, 3]` due to the `has_many` association for `authors` with `id = 1`
  - `id = [4, 5, 6]` due to the `has_many` association for `authors` with `id = 2`

Now, if instead of defining the `has_many` node at the top level, we define it under the `authors` table as follows:

```yaml
tables:
  - table: authors
    query: "select * from authors where id = 1"
    has_many:
      - books
  - table: books
    query: "select * from books where id = 6"
```

The above manifest would export the following rows:

* authors:
  - `id = 1` because of the explicit query in the manifest
  - `id = 2` because it is the `author_id` for `books` with `id = 6`

* books:
  - `id = [1, 2, 3]` due to the `has_many` association for `authors` with `id = 1`
  - `id = 6` due to the explicit query in the manifest

One potential pitfall with using `has_many` is that you end up pulling in too many associated rows when all you wanted 
was a limited number. table-saw allows you to specify a `scope` and `limit`:

```yaml
tables:
  - table: authors
    query: "select * from authors where id = 1"
  - table: books
    query: "select * from books where id = 6"
has_many:
  authors:
    - books:
        scope: "votes > 30"
        limit: 1
```

The above manifest would export the following rows:

* authors:
  - `id = 1` because of the explicit query in the manifest
  - `id = 2` because it is the `author_id` for `books` with `id = 6`

* books:
  - Either `id = 2` or `id = 3` for `author_id = 1` since they both have `vote > 30` and the limit of 1 will randomly 
    choose one of them
  - Only `id = 4` for `author_id = 2` since it's the only book for that author with `vote > 30`

#### foreign_keys
By default, table-saw will query the Postgres `information_schema` to look up the foreign key constraints and determine
whether it needs to export associated rows. However, if your database schema does not define foreign key constraints for
the tables you would like to export, you can manually define them in the manifest. Assuming we had not defined any
foreign key constraints for the `books` table, we could specify it in the manifest as follows:

```yaml
foreign_keys:
  - from_table: books
    from_column: author_id
    to_table: authors
    to_column: id
```

## Dump and Restore

Once your dump file has been created, you can import the data using `psql`:

```bash
table-saw dump -m manifest.yml -o library.dump
psql -h localhost -U postgres -d library < library.dump
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
