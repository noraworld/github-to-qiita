# frozen_string_literal: true

# Load if it is not executed via GitHub Actions
#   https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables
unless ENV['CI']
  require 'pry'
  require 'dotenv'

  Dotenv.load
end

require 'json'
require 'yaml'
require_relative 'lib/error'
require_relative 'lib/validator'
require_relative 'lib/article'
require_relative 'lib/qiita'

include Validator

Validator.env

ENV['ADDED_FILES']&.split&.each do |path|
  article = Article.new(path: path)
  qiita = Qiita.new(content: article.content, header: YAML.safe_load(article.header), mode: 'create', path: path)
  response_body = qiita.publish
  qiita.update_mapping_file(response_body['id'])
end

ENV['MODIFIED_FILES']&.split&.each do |path|
  article = Article.new(path: path)
  qiita = Qiita.new(content: article.content, header: YAML.safe_load(article.header), mode: 'update', path: path)
  qiita.publish
end
