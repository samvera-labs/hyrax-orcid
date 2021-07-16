# hyrax-orcid

Orcid integration for Hyrax/Hyku

when cloning, need to:

`git submodule init && git submodule update`

## Testing

```
 bundle exec rspec `find spec -name *_spec.rb | grep -v internal_test_hyrax`
```

## License

The gem is available as open source under the terms of the [Apache License 2.0](https://opensource.org/licenses/Apache-2.0).
