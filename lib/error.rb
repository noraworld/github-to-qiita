# frozen_string_literal: true

class QiitaAccessTokenNotFoundError < StandardError
  def initialize(msg: 'A Qiita access token is not found. The env QIITA_ACCESS_TOKEN is missing.')
    super(msg)
  end
end

class MappingFilepathNotFoundError < StandardError
  def initialize(msg: 'A mapping filepath is not found. The env MAPPING_FILEPATH is missing.')
    super(msg)
  end
end

class InvalidHeaderTitleError < StandardError
  def initialize(msg: 'A title of an article is invalid.')
    super(msg)
  end
end

class InvalidHeaderTopicsError < StandardError
  def initialize(msg: 'Topics of an article are invalid.')
    super(msg)
  end
end

class InvalidHeaderPublishedError < StandardError
  def initialize(msg: 'A published flag of an article is invalid.')
    super(msg)
  end
end

class InvalidPublishmentModeError < StandardError
  def initialize(msg: 'A publishment mode is invalid. The accepted modes are the following.', mode: nil)
    msg += " Mode: #{mode}" unless mode.nil?
    super(msg)
  end
end

class CannotGetQiitaItemIDError < StandardError
  def initialize(msg: 'Cannot get a new Qiita item ID for some reason.')
    super(msg)
  end
end

class QiitaItemIDNotFoundError < StandardError
  def initialize(msg: 'Failed to retrieve a Qiita item ID. A mapping file may be broken.')
    super(msg)
  end
end

class QiitaItemIDDuplicationError < StandardError
  def initialize(msg: 'A Qiita item ID is duplicated. Could not determine which item ID should be trusted.')
    super(msg)
  end
end

class QiitaItemIDNotMatchedError < StandardError
  def initialize(msg: 'A combination of an article path and a Qiita item ID did not match. This is most likely a Qiita item ID is missing for some reason.')
    super(msg)
  end
end

class InvalidQiitaItemIDError < StandardError
  def initialize(msg: 'A Qiita item ID is invalid.')
    super(msg)
  end
end

class QiitaAPIError < StandardError
  TRUNCATED_LENGTH = 100
  OMISSION = '...'

  def initialize(msg: 'A Qiita API returns a non-succeeded status.', data: nil)
    unless data.nil?
      msg += " Status code: #{data[:response].status}," \
             " Request headers: #{conceal_token(data[:response].env.request_headers)}," \
             " Request body: #{JSON.parse(data[:response].env.request_body)}," \
             " Response headers: #{data[:response].headers}," \
             " Response body: #{JSON.parse(data[:response].body)}," \
             " Mode: \"#{data[:mode]}\"," \
             " Path: \"#{data[:path]}\""
    end

    super(msg)
  end

  private

  def conceal_token(headers)
    # Do NOT return this value because Hash#delete returns a DELETED value
    #
    # { foo: 42, bar: 'Lorem ipsum', want_to_delete: 'deleted_value' }.delete(:want_to_delete)
    # => "deleted_value"
    #
    # Do return a receiver object instead
    #
    headers.delete('Authorization')

    headers
  end
end
