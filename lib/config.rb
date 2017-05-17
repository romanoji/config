require 'active_support/core_ext/module/attribute_accessors'

require 'config/compatibility'
require 'config/options'
require 'config/version'
require 'config/integrations/rails/engine' if defined?(::Rails)
require 'config/sources/yaml_source'
require 'config/sources/hash_source'
require 'config/validation/schema' if RUBY_VERSION >= '2.1'
require 'deep_merge'

module Config
  extend Config::Validation::Schema if RUBY_VERSION >= '2.1'

  # Ensures the setup only gets run once
  @@_ran_once = false

  mattr_accessor :const_name, :use_env, :env_prefix, :env_separator,
                 :env_converter, :env_parse_values, :extra_sources
  @@const_name = 'Settings'
  @@use_env    = false
  @@env_prefix = @@const_name
  @@env_separator = '.'
  @@env_converter = :downcase
  @@env_parse_values = true
  @@extra_sources = []

  # deep_merge options
  mattr_accessor :knockout_prefix, :overwrite_arrays
  @@knockout_prefix = nil
  @@overwrite_arrays = true

  def self.setup
    yield self if @@_ran_once == false
    @@_ran_once = true
  end

  # Create a populated Options instance from a settings source. If a second source is given, then the sections of that
  # source will overwrite existing sections of the first source.
  # Source can be either file or hash.
  def self.load_sources(*sources)
    config = Options.new

    # add settings sources
    [sources].flatten.compact.uniq.each do |source|
      config.add_source!(source)
    end

    config.load!
    config.load_env! if @@use_env
    config
  end

  # Loads and sets the settings constant!
  def self.load_and_set_settings(*sources)
    Kernel.send(:remove_const, Config.const_name) if Kernel.const_defined?(Config.const_name)
    Kernel.const_set(Config.const_name, Config.load_sources(sources))
  end

  def self.add_extra_source(source)
    extra_sources << source
  end

  def self.setting_files(config_root, env)
    [
      File.join(config_root, "settings.yml").to_s,
      File.join(config_root, "settings", "#{env}.yml").to_s,
      File.join(config_root, "environments", "#{env}.yml").to_s,

      File.join(config_root, "settings.local.yml").to_s,
      File.join(config_root, "settings", "#{env}.local.yml").to_s,
      File.join(config_root, "environments", "#{env}.local.yml").to_s
    ].freeze
  end

  def self.reload!
    Kernel.const_get(Config.const_name).reload!
  end
end

# Rails integration
require('config/integrations/rails/railtie') if defined?(::Rails)

# Sinatra integration
require('config/integrations/sinatra') if defined?(::Sinatra)
