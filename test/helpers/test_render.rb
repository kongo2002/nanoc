require 'test/helper'

class Nanoc::Helpers::RenderTest < MiniTest::Unit::TestCase

  def setup    ; global_setup    ; end
  def teardown ; global_teardown ; end

  include Nanoc::Helpers::Render

  def test_render
    # Mock layouts
    layout = MiniTest::Mock.new
    layout.expect(:identifier,   '/foo/')
    layout.expect(:content,      'This is the <%= @layout.identifier %> layout.')
    layout_proxy = MiniTest::Mock.new
    layout_proxy.expect(:identifier, '/foo/')
    layout.expect(:to_proxy, layout_proxy)

    # Mock site, compiler and stack
    stack    = []
    compiler = MiniTest::Mock.new
    compiler.expect(:stack, stack)
    compiler.expects(:filter_name_for_layout).with(layout).returns(:erb)
    @site    = MiniTest::Mock.new
    @site.expect(:compiler, compiler)
    @site.expect(:layouts, [ layout ])

    # Render
    assert_equal('This is the /foo/ layout.', render('/foo/'))
  end

  def test_render_with_unknown_layout
    # Mock site
    @site = MiniTest::Mock.new.expect(:layouts, [])

    # Render
    assert_raises(Nanoc::Errors::UnknownLayoutError) do
      render('/fawgooafwagwfe/')
    end
  end

  def test_render_without_filter
    # Mock layouts
    layout = MiniTest::Mock.new
    layout.expect(:identifier,   '/foo/')
    layout.expect(:content,      'This is the <%= "foo" %> layout.')
    layout_proxy = MiniTest::Mock.new
    layout.expect(:to_proxy, layout_proxy)

    # Mock compiler
    compiler = mock
    compiler.stubs(:filter_name_for_layout).with(layout).returns(nil)

    # Mock site
    @site = MiniTest::Mock.new
    @site.expect(:layouts, [ layout ])
    @site.expect(:compiler, compiler)

    # Render
    assert_raises(Nanoc::Errors::CannotDetermineFilterError) do
      render '/foo/'
    end
  end

  def test_render_with_unknown_filter
    # Mock layouts
    layout = MiniTest::Mock.new
    layout.expect(:identifier,   '/foo/')
    layout.expect(:content,      'This is the <%= "foo" %> layout.')
    layout_proxy = MiniTest::Mock.new
    layout.expect(:to_proxy, layout_proxy)

    # Mock compiler
    compiler = mock
    compiler.stubs(:filter_name_for_layout).with(layout).returns(:kjsdalfjwagihlawfji)

    # Mock site
    @site = MiniTest::Mock.new
    @site.expect(:layouts, [ layout ])
    @site.expect(:compiler, compiler)

    # Render
    assert_raises(Nanoc::Errors::UnknownFilterError) do
      render '/foo/'
    end
  end

end
