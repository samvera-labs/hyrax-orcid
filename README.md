# hyrax-orcid

Orcid integration for Hyrax/Hyku

## Install

Add the following to your Gemfile:

```ruby
gem 'hyrax-orcid', git: 'https://github.com/ubiquitypress/hyrax-orcid', branch: 'main'
```

The installer will copy over any migrations and insert the assets into your applications asset pipeline. Just run the following:

```bash
bundle exec rails g hyrax:orcid:install
bundle exec rails db:migrate
```

## Configuration

Add an initializer to your app with the following block:

```ruby
Hyrax::Orcid.configure do |config|
  # :sandbox or :production
  config.environment = :sandbox

  config.auth = {
    client_id: "YOUR-APP-ID",
    client_secret: "your-secret-token",
    # The authorisation return URL you entered when creating the Orcid Application. Should be your repository URL and `/dashboard/orcid_identity/new`
    redirect_url: "http://your-repo.com/dashboard/orcid_identity/new"
  }

  config.bolognese = {
    # The work reader method, excluding the _reader suffix
    reader_method: "hyrax_json_work",
    # The writer class that provides the XML body which is sent to Orcid
    xml_writer_class_name: "Bolognese::Writers::Xml::WorkWriter"
  }

  config.active_job_type = :perform_later
  config.work_types = ["YourWorkType", "GenericWork"]
end
```

You can also set the following ENV varibles before your app starts:

```bash
ORCID_ENVIRONMENT: sandbox
ORCID_CLIENT_ID: YOUR-APP-ID
ORCID_CLIENT_SECRET: your-secret-token
ORCID_AUTHORIZATION_REDIRECT: http://your-repo.com/dashboard/orcid_identity/new
```

You can then access the values like so `reader_method = Hyrax::Orcid.configuration.bolognese[:reader_method]`

## Integration into Hyku

Hyrax Orcid is designed to be used with Hyrax, but you can also use it with Hyku if you perform a few manual tasks.

First, include the Helper methods into your application:

```ruby
include Hyrax::Orcid::HelperBehavior
```

Add the assets to your application.{js, css}:

```js
//= require hyrax/orcid/application
```

```css
*= require hyrax/orcid/application
```

Within the Dashboard, go to `Settings/Features` and enable the Hyrax Orcid feature flipper.

### Integration into HykuAddons

HykuAddons is an opinionated addition to Hyku. Go to `Settings/Account Settings` and enter your Orcid application authorisation credentials into the correct fields under "Hyrax orcid settings".

## Activating for a model

Add the following to your work models, `include Hyrax::Orcid::WorkBehavior`.

## Testing

```bash
docker-compose exec web bundle exec rspec

```

## Development

When cloning, you will need to run from the `spec/internal_test_hyrax` folder:

`git submodule init && git submodule update`

### Potential Issues

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

I've had issues with the tasks, so if it's still not working, login with the Admin user and create a new Admin Set Collection manually with the title "admin_set/default"

## TODO

There are a number of outstanding items that should be addressed in the future:

### Hyrax Orcid Gem

+ JSON fields should be extracted into its own Gem allowing configuration via YML - this is on the HA developers list but time hasn't been found

### Hyku/HykuAddons related items

Because this Gem was developed to eventually work with Hyku Addons, there are a number of items that are Hyku/HykuAddons related:

+ Orcid Types are all 'other', there needs to be a map between Orcid Work Types and Hyrax Work Types, please see HyraxXmlBuilder for a list of types
+ The Orcid Contributor types need to be mapped to Hyrax Work Contributor types

## To Investigate

+ What happens when a public work is published, then made restricted - I think it is likely it will fail to write the update because of the visibility check within the `PublishWorkActive`

## License

The gem is available as open source under the terms of the [Apache License 2.0](https://opensource.org/licenses/Apache-2.0).
