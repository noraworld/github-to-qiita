# frozen_string_literal: true

class Article
  def initialize(path:)
    @path = path
  end

  # Get a content of an article file without a YAML header
  def content
    File.open(@path, 'r') do |file|
      file.read.gsub(/\A#{Regexp.escape("---\n" + header + '---')}/, '').gsub(/\A\n+/, '')
    end
  end

  # Get a YAML header of an article file
  def header
    header = ''

    File.open(@path, 'r') do |file|
      file.each_line.with_index do |line, index|
        next  if index.zero?    && line =~ /^---/ # Go onto next if the first "---" line of the YAML header
        break if index.nonzero? && line =~ /^---/ # Break if the last "---" line of the YAML header

        header += line
      end
    end

    header
  end
end
