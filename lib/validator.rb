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
  end

  # Check required header params
  def header(params)
    raise InvalidHeaderTitleError unless title_valid?(params['title'])
    raise InvalidHeaderTopicsError unless topics_valid?(params['topics'])
    raise InvalidHeaderPublishedError unless published_valid?(params['published'])
  end

  def mode(param)
    raise InvalidPublishmentModeError.new(mode: PUBLISHMENT_MODE) unless PUBLISHMENT_MODE.include?(param)
  end

  def item_id(id)
    raise InvalidQiitaItemIDError if id&.match(/\A[0-9a-f]{20}\z/).nil?
  end

  private

  def title_valid?(param)
    return false if param.nil?
    return false unless param.is_a?(String)
    return false if param.empty?

    true
  end

  def topics_valid?(params)
    return false if params.nil?
    return false unless params.is_a?(Array)
    return false if params.empty?
    return false unless params.all? { |element| element.is_a?(String) }
    return false if params.any? { |element| element.empty? }

    true
  end

  def published_valid?(param)
    return false if param.nil?
    return false if param != true && param != false

    true
  end
end
