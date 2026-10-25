# Gift Card API

JSON API for a gift card platform.
Rails 8.1 (API mode), Ruby 3.4, PostgreSQL, Redis, RSpec, JWT.

## Setup

```sh
cp .env.example .env
bundle install
bin/rails db:prepare
bin/rails s
```

## Tests

```sh
bundle exec rspec
RAILS_ENV=test bundle exec rake rswag:specs:swaggerize   # regenerate swagger
```

## API

Docs: `/api-docs` (Swagger UI).
