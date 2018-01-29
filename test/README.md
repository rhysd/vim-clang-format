How to run the tests
====================

## Prerequisities

- Ruby 1.9 or higher
- Rake
- Bundler

## How to run tests

Following command does everything to run tests.

```
$ rake test
```

Or you can also run `vim-flavor` directly.

```
$ bundle install --path=.bundle
$ bundle exec vim-flavor test
```

## How to watch file changes and run tests automatically

```
$ rake watch
```

It requires guard gem.
