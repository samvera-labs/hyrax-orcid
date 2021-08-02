# hyrax-orcid

Orcid integration for Hyrax/Hyku

when cloning, need to:

`git submodule init && git submodule update`

## Activating for a model

In your model, include the `Hyrax::Orcid::WorkBehavior` concern

## Testing

```bash
bundle exec rspec `find spec -name *_spec.rb | grep -v internal_test_hyrax`
```

When running the specs, if yousee the following error:

```bash
Failure/Error: work.save

      Ldp::Conflict:
        Can't call create on an existing resource (http://fcrepo:8080/fcrepo/rest/test/5t/34/sj/56/5t34sj56t)
```

You can try to remove the volumes for the app - this will however mean you need to recreate the repositories.

```bash
dc down --volumes; dc build; dc up -d web; docker attach hyrax-orcid_web_1
```


## License

The gem is available as open source under the terms of the [Apache License 2.0](https://opensource.org/licenses/Apache-2.0).
