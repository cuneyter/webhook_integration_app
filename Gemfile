source "https://rubygems.org"

ruby File.read(".ruby-version").strip

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0", ">= 8.0.2"
# Use Propshaft as the asset pipeline [https://github.com/rails/propshaft]
gem "propshaft", "~> 1.2"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.6"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails", "~> 4.3"
# PropsTemplate is a direct-to-Oj, JBuilder-like DSL for building JSON.
# It has support for Russian-Doll caching, layouts, and can be queried by giving the root a key path.
gem "props_template", "~> 0.38.0"

# Rails 8 Solid Adapters - Database-backed alternatives to Redis
# Use Solid Cable to run Action Cable in production [https://github.com/rails/solid_cable]
# Solid Cable is a database-backed Action Cable adapter that provides a reliable
# and scalable solution for real-time features.
gem "solid_cable", "~> 3.0"

# Use Solid Cache to run Action Cable in production [https://github.com/rails/solid_cache]
# Solid Cache is a database-backed cache store that provides a reliable and scalable solution for caching.
gem "solid_cache", "~> 1.0", ">= 1.0.7"

# Use Solid Job to run background jobs in production [https://github.com/rails/solid_queue/]
# Solid Job is a database-backed Active Job backend that provides a reliable and scalable solution for background processing.
gem "solid_queue", "~> 1.2"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# HTTP/REST API client library.
gem "faraday", "~> 2.13"

# HTTP client library.
gem "http", "~> 5.3"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
  gem "factory_bot_rails"
  gem "rspec-rails"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add a comment summarizing the current schema
  gem "annotate"

  # Provides security analysis feature.
  gem "ruby-lsp-brakeman", require: false
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "webmock"
  gem "shoulda-matchers", "~> 6.5"
end
