# hyrax-orcid

Orcid integration for Hyrax/Hyku

when cloning, need to:

`git submodule init && git submodule update`

## Activating for a model

In your model, include the `Hyrax::Orcid::WorkBehavior` concern

## Install

The installer will copy over any migrations and insert the assets into your applications asset pipeline. Just run the following:

```bash
bundle exec rails g hyrax:orcid:install
bundle exec rails db:migrate
```

## Configuration

Add an initializer to your app with the following block:

```ruby
Hyrax::Orcid.configure do |config|
  config.client_id = "YOUR-APP-ID"
  config.client_secret = "your-secret-token"
  config.authorization_redirect_url = "http://your-repo.com/dashboard/orcid_identity/new"
end
```

You can also set the following ENV varibles before your app starts:

```bash
ORCID_CLIENT_ID: YOUR-APP-ID
ORCID_CLIENT_SECRET: your-secret-token
ORCID_AUTHORIZATION_REDIRECT: http://your-repo.com/dashboard/orcid_identity/new
```

## Testing

```bash
bundle exec rspec `find spec -name *_spec.rb | grep -v internal_test_hyrax`
```

## Development

The app uses an sqlite database which is stored inside `spec/internal_test_hyrax/db`. If you wish to nuke your app and start again, delete this file,
then you will need to ensure that the db is created, migrations are run and seeds imported before the app will start, by using something like this to start the web container:

```
command: bash -c "rm -f spec/internal_test_hyrax/tmp/pids/server.pid && bundle exec rails db:create && bundle exec rails db:migrate && bundle exec rails server -b 0.0.0.0"
```

You will need to create a new user before you can login. Admin users are found within the `spec/internal_test_hyrax/config/role_map.yml`. Login to the rails console and create a user:

```ruby
User.create(email: 'archivist1@example.com', password: 'test1234')
```

If you get to a situation where you cannot create works, your admin set might be missing:

```ruby
rails app:hyrax:default_collection_types:create;
rails app:hyrax:default_admin_set:create
```

## License

The gem is available as open source under the terms of the [Apache License 2.0](https://opensource.org/licenses/Apache-2.0).
