TEST_DIR = File.expand_path(File.dirname(__FILE__))
ROOT_DIR = File.expand_path(File.join(TEST_DIR, ".."))
$LOAD_PATH.unshift File.join(ROOT_DIR, "lib")

require 'rubygems'
require 'rubygems/version'

require 'minitest/autorun'

require 'gem2rpm'

# If you want to test in off line environment, set environment variable.
def skip_if_offline
  skip('Skip test because of off line') if ENV['TEST_GEM2RPM_LOCAL']
end

def config
  Gem2Rpm::Configuration.instance
end

def testing_tmp_dir
  @testing_tmp_dir ||= File.join(ROOT_DIR, "tmp")
end

def gem_file_name
  @gem_file_name ||= "testing_gem-1.0.0.gem"
end

def gem_path
  @gem_path ||= File.join(TEST_DIR,
    "artifacts", "testing_gem", gem_file_name)
end

def vagrant_plugin_path
  @vagrant_plugin_path ||= File.join(TEST_DIR,
    "artifacts", "vagrant_plugin", "vagrant_plugin-1.0.0.gem")
end
