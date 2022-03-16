# frozen_string_literal: true

module Validator
  # MEMO: 'delete' is not implemented
  PUBLISHMENT_MODE = %w[
    create
    update
  ].freeze

  # It does not check an access token format is valid because it is subject to change
  def env
    raise QiitaAccessTokenNotFoundError if ENV['QIITA_ACCESS_TOKEN'].nil? || ENV['QIITA_ACCESS_TOKEN'].empty?
    raise MappingFilepathNotFoundError if ENV['MAPPING_FILEPATH'].nil? || ENV['MAPPING_FILEPATH'].empty?
    raise InvalidStrictError.new(msg: 'The env STRICT is missing.') if ENV['STRICT'].nil? || ENV['STRICT'].empty?

    if ENV['STRICT'] != 'true' && ENV['STRICT'] != 'false'
      raise InvalidStrictError.new(msg: 'The env STRICT must be true or false')
    end
  end

  # Check required header params
  def header(params)
    title(params['title'])
    topics(params['topics'])
    published(params['published'])
  end

  def mode(param)
    raise InvalidPublishmentModeError.new(mode: PUBLISHMENT_MODE) unless PUBLISHMENT_MODE.include?(param)
  end

  def item_id(id)
    raise InvalidQiitaItemIDError if id&.match(/\A[0-9a-f]{20}\z/).nil?
  end

  private

  def title(param)
    raise InvalidHeaderTitleError.new(msg: 'A title of an article is missing.') if param.nil?
    raise InvalidHeaderTitleError.new(msg: 'A title of an article must be a string.') unless param.is_a?(String)
    raise InvalidHeaderTitleError.new(msg: 'A title of an article must not be empty.') if param.empty?
  end

  def topics(params)
    raise InvalidHeaderTopicsError.new(msg: 'Topics of an article are missing.') if params.nil?
    raise InvalidHeaderTopicsError.new(msg: 'Topics of an article must be an array.') unless params.is_a?(Array)
    raise InvalidHeaderTopicsError.new(msg: 'Topics of an article must not be empty.') if params.empty?

    unless params.all? { |element| element.is_a?(String) }
      raise InvalidHeaderTopicsError.new(msg: 'All the elements of topics must be a string.')
    end

    if params.any? { |element| element.empty? }
      raise InvalidHeaderTopicsError.new(msg: 'The elements of topics must not be empty.')
    end

    if (params.count - params.uniq.count).positive?
      raise InvalidHeaderTopicsError.new(msg: 'There are duplicated topics.')
    end

    if params.any? { |param| param.include?(' ') }
      raise InvalidHeaderTopicsError.new(msg: 'A topic including spaces is not acceptable.')
    end
  end

  def published(param)
    raise InvalidHeaderPublishedError.new(msg: 'A published flag of an article is missing.') if param.nil?

    if param != true && param != false
      raise InvalidHeaderPublishedError.new(msg: 'A published flag of an article must be true or false.')
    end
  end
end
