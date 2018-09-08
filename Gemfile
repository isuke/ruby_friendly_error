# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in ruby_friendly_error.gemspec
gemspec

group :development, :test do
  gem 'pry-byebug', '~> 3.6'
  gem 'rubocop-rspec', '~> 1.28'
end

group :test do
  gem 'rspec', '~> 3.0'
end
