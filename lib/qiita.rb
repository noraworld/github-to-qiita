# frozen_string_literal: true

require 'faraday'

class Qiita
  API_BASE_URL = 'https://qiita.com'
  API_ITEM_ENDPOINT = '/api/v2/items'

  # @content: String: A content of an article
  # @header:  Hash:   A YAML header of an article
  # @mode:    String: A value to indicate that an article is created, updated, or deleted
  # @path:    String: A path where an article exists
  def initialize(content:, header:, mode:, path:)
    Validator.header(header)
    Validator.mode(mode)

    @content = content
    @header = header
    @mode = mode
    @path = path

    create_mapping_file_if_not_exists
  end

  # Publish an article to Qiita
  #
  # Returns a parsed response body
  # https://qiita.com/api/v2/docs
  #
  def publish
    connection = Faraday.new(API_BASE_URL)

    response = case @mode
    when 'create'
      connection.post(&request_params)
    when 'update'
      connection.patch(&request_params)
    end

    unless response.success?
      raise QiitaAPIError.new(
        data: {
          response: response,
          mode: @mode,
          path: @path
        }
      )
    end

    JSON.parse(response.body)
  end

  # Update a mapping file
  def update_mapping_file(item_id)
    raise CannotGetQiitaItemIDError if item_id.nil? || item_id.empty?
    Validator.item_id(item_id)

    File.open(ENV['MAPPING_FILEPATH'], 'a') do |file|
      file.puts "#{@path}, #{item_id}"
    end
  end

  private

  def request_params
    Proc.new do |request|
      request.url(request_url)
      request.headers['Authorization'] = "Bearer #{ENV['QIITA_ACCESS_TOKEN']}"
      request.headers['Content-Type'] = 'application/json'
      request.headers['User-Agent'] = 'GitHub to Qiita'
      request.headers['Origin'] = API_BASE_URL
      request.body = request_body
    end
  end

  def request_url
    id = @mode == 'update' ? "/#{item_id}" : nil

    "#{API_ITEM_ENDPOINT}#{id}"
  end

  def request_body
    body = {
      body: @content.force_encoding('UTF-8'),
      coediting: false,
      group_url_name: nil,
      private: private?,
      tags: tags,
      title: @header['title']
    }.freeze

    body = body.merge(tweet: public?) if @mode == 'create'

    body.to_json
  end

  def public?
    @header['published']
  end

  def private?
    !@header['published']
  end

  # Get tags from a YAML header
  #
  # [
  #   { name: 'PulseAudio' },
  #   { name: 'Bluetooth' },
  #   { name: 'RaspberryPi' }
  # ]
  #
  def tags
    @header['topics'].map { |topic| { name: topic } }
  end

  # Get a Qiita item ID corresponding to an article path
  def item_id
    # An error handling
    raise QiitaItemIDNotFoundError if mappings.grep(/\A^#{Regexp.escape(@path)}/).empty?
    raise QiitaItemIDDuplicationError if mappings.grep(/\A^#{Regexp.escape(@path)}/).length != 1
    raise QiitaItemIDNotMatchedError if mappings.grep(/\A^#{Regexp.escape(@path)}/).first.split.length != 2
    if mappings.grep(/\A^#{Regexp.escape(@path)}/).first.split.last.match(/\A[0-9a-f]{20}\z/).nil?
      raise InvalidQiitaItemIDError
    end

    mappings.grep(/\A^#{Regexp.escape(@path)}/).first.split.last
  end

  # Get a content of a mapping file
  #
  # [
  #   "articles/heroku-postdeploy-runs-only-once.md, 1c57bd07cf0eb8ae807e",
  #   "articles/heroku-rails-mysql.md, 09dac6e4340b85e35be4",
  #   "articles/rails-command-hangs.md, 5f0f0a9bba2ec1dfab67"
  # ]
  #
  def mappings
    File.open(ENV['MAPPING_FILEPATH'], 'r') do |file|
      file.read.split("\n")
    end
  end

  def create_mapping_file_if_not_exists
    File.new(ENV['MAPPING_FILEPATH'], 'a') if File.exist?(ENV['MAPPING_FILEPATH'])
  end
end
