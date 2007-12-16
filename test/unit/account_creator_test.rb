################################################################################
require File.dirname(__FILE__) + '/../test_helper'

################################################################################
class AccountCreatorTest < Test::Unit::TestCase

  ################################################################################
  class User < ActiveRecord::Base; end

  ################################################################################
  def test_can_create_users
    user_count = User.count
    assert_not_nil(user_count)

    account_count = Rauth::Source::Native.count
    assert_not_nil(account_count)

    ac = Rauth::AccountCreator.new(Rauth::Source::Native)
    status = ac.create(User.new, :user_name => 'foo', :password => 'foobar')
    assert(status)
    assert_equal(user_count+1, User.count)
    assert_equal(account_count+1, Rauth::Source::Native.count)
  end

end
