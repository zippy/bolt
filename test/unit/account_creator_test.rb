################################################################################
require File.dirname(__FILE__) + '/../test_helper'

################################################################################
# Test that identities can be created from the user model
class AccountCreatorTest < Test::Unit::TestCase

  ################################################################################
  class FakeUserModel < ActiveRecord::Base
    include(Bolt::UserModelExt)
    def initialize () end # necessary to keep Rails from barfing
  end

  ################################################################################
  def test_can_create_identities
    account_count = Identity.count
    assert_not_nil(account_count)
    fake_user = new_fake_user
    assert(fake_user.create_bolt_identity(:password => 'foobar'))
    assert_not_nil(fake_user.instance_variable_get(:@bolt_identity))
    assert_equal(account_count+1, Identity.count)
  end

  ################################################################################
  def test_activation_code
    fake_user = new_fake_user
    code = fake_user.create_bolt_identity(:password => 'foobar', :activation => true)
    assert(code)
    assert(code.is_a?(String))
    assert_equal(fake_user.instance_variable_get(:@bolt_identity).activation_code, code)
  end

  ################################################################################
  private
  
  ################################################################################
  def new_fake_user
    fake_user = FakeUserModel.new
    fake_user.expects(:email).returns('foobar@example.com')
    fake_user.expects(:save!).returns(true)
    fake_user.expects(:bolt_identity_id=)
    fake_user
  end
  
end
