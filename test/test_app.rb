require 'helper'

class TestApp < Minitest::Test
  def setup
    super
    @app = Gem2Rpm::App.new
  end

  def teardown
    super
  end

  def test_run_gem_file

  end

  def test_run_templates
  end

  def test_build_rpm

  end
end
