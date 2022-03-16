# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.1.1'

gem 'faraday'

# For development
#
# These gems should be installed only for development environment, but
# `bundle config set --local without 'development,test'` cannot be
# used because it stores the configuration in `.bundle/config`, and
# this file is hard to track on Git
#
# By the way, `--without` option is deprecated
#
# ENV['CI'] is only set on GitHub Actions
#
unless ENV['CI']
  gem 'dotenv'
  gem 'pry-byebug'
end
