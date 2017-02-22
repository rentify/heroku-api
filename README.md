# This gem is no longer maintained

Please use the official [Heroku platform-api](https://github.com/heroku/platform-api) gem

---

# Heroku

Create, destroy and manage your heroku applications programmatically, using the Heroku Platform API.

## Installation

Add this line to your application's Gemfile:

    gem 'heroku-platform-api'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install heroku-platform-api

## Usage

### Require the gem

    require 'heroku_api'
    # => true

### Configuration

    Heroku::API.configure do |c|
      c.api_key = "<Heroku API token>" # Mandatory
      c.logger  = Logger.new($stdout)  # Optional
    end

### Apps

The `Heroku::API.apps` object can be treated as though it were an `Array` of applications
with the below methods added.

#### Creating a new App

    app = Heroku::API.apps.new(name: "example", region: {name: 'us'}, stack: 'cedar')
    # => #<Heroku::Model::App id="01234567-89ab-cdef-0123-456789abcdef", name="example">

All the parameters provided are optional, if this end-point is called without them,
then defaults will be chosen.

#### Listing all Available Apps

    Heroku::API.apps.all
    # => [#<Heroku::Model App...>,...]

#### Searching for a Particular App

    Heroku::API.apps["example"]
    # => #<Heroku::Model::App id="01234567-89ab-cdef-0123-456789abcdef", name="example">

OR

    Heroku::API.apps.app("example")
    # => #<Heroku::Model::App id="01234567-89ab-cdef-0123-456789abcdef", name="example">

#### Updating an Existing App

    app.name = "my_app" # Name and heroku based sub-domain of app.
    app.maintenance = true # Maintenance mode on.
    app.save
    # => #<Heroku::Model::App id="01234567-89ab-cdef-0123-456789abcdef", name="my_app">

#### Pushing to an Existing App

This gem provides rudimentary support for pushing a given git repo to be deployed
as the app, by simplying providing the directory of the repo:

    app.push("path/to/repository")
    # => true

### Account

#### Getting the account details

    acc = Heroku::API.account
    # => #<Heroku::Model::Account id="01234567-89ab-cdef-0123-456789abcdef", email="username@example.com">

#### Updating the account details

    acc.email = "joe-bloggs@example.com"
    acc.allow_tracking = false # Let third party tracking services track you.
    acc.save
    # => #<Heroku::Model::Account id="01234567-89ab-cdef-0123-456789abcdef", email="joe-bloggs@example.com">

#### Changing the account password

    acc.update_password("new_password", "old_password")
    # => true

OR

    Heroku::API.update_password("new_password", "old_password")
    # => true

### Rate Limits

You can check the number of requests left like so:

    Heroku::API.account.rate_limits
    # => 1200

OR

    Heroku::API.rate_limits
    # => 1200

### Regions

Find out the available regions with:

    Heroku::API.regions
    # => [{"created_at"=>"2012-11-21T21:44:16Z", "description"=>"United States", "id"=>"59accabd-516d-4f0e-83e6-6e3757701145", "name"=>"us", "updated_at"=>"2013-04-05T10:13:06Z"}, {"created_at"=>"2012-11-21T22:05:26Z", "description"=>"Europe", "id"=>"ed30241c-ed8c-4bb6-9714-61953675d0b4", "name"=>"eu", "updated_at"=>"2013-04-05T07:07:28Z"}]

### Further API endpoints

The Heroku Platform API Gem does not currently support any further API end-points
natively. If you would like to add them, feel free to contribute, as directed below.

If you would like to test the various endpoints that are not currently fully
supported, please use the `Heroku::Conn` class, which will return the requested
data as Ruby Arrays and Hashes:

*Raw request for rate limit*

    etag, response = Heroku::Conn::Get('/account/rate-limits'); response
    # => { 'remaining' => '1200' }

For further information, visit the [Heroku Platform API](https://devcenter.heroku.com/articles/platform-api-reference).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
