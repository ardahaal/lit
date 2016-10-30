require 'lit/engine'
require 'lit/loader'

module Lit
  mattr_accessor :authentication_function
  mattr_accessor :authentication_verification
  mattr_accessor :key_value_engine
  mattr_accessor :storage_options
  mattr_accessor :humanize_key
  mattr_accessor :ignored_keys
  mattr_accessor :fallback
  mattr_accessor :api_enabled
  mattr_accessor :api_key
  mattr_accessor :all_translations_are_html_safe
  mattr_accessor :set_last_updated_at_upon_creation
  mattr_accessor :overwrite_helper

  class << self
    attr_accessor :loader
  end

  def self.init
    @@table_exists ||= check_if_table_exists
    puts @@table_exists
    puts check_if_table_exists
    if loader.nil? && @@table_exists
      self.loader ||= Loader.new
      Lit.humanize_key = false if Lit.humanize_key.nil?
      Lit.fallback = true if Lit.fallback.nil?
      if Lit.ignored_keys.is_a?(String)
        keys = Lit.ignored_keys.split(',').map(&:strip)
        Lit.ignored_keys = keys
      end
      Lit.ignored_keys = [] unless Lit.ignored_keys.is_a?(Array)
      # if loading all translations on start, migrations have to be already
      # performed, fails on first deploy
      # self.loader.cache.load_all_translations
      Lit.storage_options ||= {}
    end
    self.loader
  end

  def self.check_if_table_exists
    Lit::Locale.table_exists?
  end

  def self.get_key_value_engine
    case Lit.key_value_engine
    when 'redis'
      require 'lit/adapters/redis_storage'
      return RedisStorage.new
    else
      require 'lit/adapters/hash_storage'
      return HashStorage.new
    end
  end
end

if defined? Rails
  require 'lit/rails'
end
