################################################################################
require File.dirname(__FILE__) + '/../test_helper'

################################################################################
class RoleTest < Test::Unit::TestCase
  ################################################################################
  Engines::Testing.set_fixture_path
  fixtures(:roles, :permissions, :allowances)

  ################################################################################
  def test_helper_methods
    admin = roles(:admin)
    assert_not_nil(admin)

    # Check that #authorize is successful
    create_blog = admin.authorize(:create_blog)
    assert_not_nil(create_blog)
    assert_equal(permissions(:create_blog), create_blog.permission)
    assert_equal(0, create_blog.allowance)

    # Make sure #authorize fails
    assert_nil(admin.authorize(:foo_bar_wtf))

    # Make sure #can? works
    assert(admin.can?(:create_blog))
    assert(!admin.can?(:foo_bar_wtf))
  end

  ################################################################################
  def test_allowance_add
    loser = roles(:loser)
    assert_not_nil(loser)
    assert_equal(0, loser.allowances.count)
    assert_equal(0, loser.permissions.count)

    loser.allowances.add(:edit_article)
    assert_equal(1, loser.allowances.count)
    assert_equal(1, loser.authorize(:edit_article).allowance)
    assert(loser.can?(:edit_article))

    loser.allowances.add(:post_article, 5)
    assert_equal(5, loser.authorize(:post_article).allowance)
    assert(loser.can?(:post_article))

    # return loser for other tests to use
    loser
  end

  ################################################################################
  def test_allowance_remove
    loser = test_allowance_add
    assert_not_nil(loser)
    assert_equal(2, loser.allowances.count)
    assert(loser.can?(:edit_article))
    loser.allowances.remove(:post_article, :edit_article, :nothing)
    assert(!loser.can?(:edit_article))
  end

  ################################################################################
  def test_allowance_reset
    loser = test_allowance_add
    assert_not_nil(loser)

    loser.allowances.reset!(:post_article => 6)
    assert_equal(1, loser.allowances.count)
    assert(loser.can?(:post_article))
    assert_equal(6, loser.authorize(:post_article).allowance)

    loser.allowances.reset!(:edit_article)
    assert_equal(1, loser.allowances.count)
    assert(loser.can?(:edit_article))
    assert_equal(1, loser.authorize(:edit_article).allowance)
  end

end
################################################################################
