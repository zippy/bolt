################################################################################
require File.dirname(__FILE__) + '/../test_helper'

################################################################################
class IdentityTest < Test::Unit::TestCase
  ################################################################################
  Engines::Testing.set_fixture_path
  fixtures(:identities)

  ################################################################################
  # Make sure the password validation system works
  def test_password
    pjones = identities(:pjones)
    assert(pjones.password?('foobar'))
    assert(!pjones.password?('barfoo'))
  end

  ################################################################################
  # Make sure the authentication system works
  def test_authenticate
    assert_equal(identities(:pjones), Identity.authenticate('pjones@pmade.com', 'foobar'))
    assert_nil(Identity.authenticate('pjones@pmade.com', 'barfoo'))
  end

  ################################################################################
  # Make sure that whitespace and case in the user name don't matter
  def test_user_name
    pjones = identities(:pjones)

    [
      'PJONES@pmade.com', 
      ' pjones@pmade.com ',
      ' Pjones@pmade.com',
    ].each {|u| assert_equal(pjones, Identity.authenticate(u, 'foobar'))}
  end

  ################################################################################
  # Test password change
  def test_password_change
    pjones = identities(:pjones)

    # should work
    pjones.password_with_confirmation("barfoo", "barfoo")
    assert(pjones.save)

    # password confirmation error
    pjones.password_with_confirmation("foobar", "barfoo")
    assert(!pjones.save)

    # length error
    pjones.password_with_confirmation("foo", "foo")
    assert(!pjones.save)

    # should work
    pjones.password_with_confirmation("foobar", "foobar")
    assert(pjones.save)
  end

  ################################################################################
  # Make sure the activation stuff works
  def test_activation
    pjones = identities(:pjones)
    assert(pjones.enabled?)
    assert(pjones.activation_code.blank?)
    assert(!pjones.require_activation?)

    code = pjones.require_activation!
    assert(!code.blank?)
    assert_equal(code, pjones.activation_code)
    assert(pjones.require_activation?)
    assert(!pjones.enabled?)
    assert(pjones.save)

    acct = Identity.activate!(pjones.user_name, code.downcase)
    assert_not_nil(acct)
    assert(acct.enabled?)
    assert(!acct.require_activation?)

    # This should fail because the account no longer has an activation code
    acct = Identity.activate!(pjones.user_name, code)
    assert_nil(acct)
  end

  ################################################################################
  # Make sure the password resetting stuff works
  def test_reset_code
    pjones = identities(:pjones)
    assert(pjones.reset_code.blank?)
    assert(pjones.enabled?)

    code = pjones.reset_code!
    assert(!code.blank?)
    assert_equal(code, pjones.reset_code)
    assert(pjones.enabled?)
    assert(pjones.save)

    acct = Identity.reset_password!(pjones.user_name, code, 'testme', 'testme')
    assert_not_nil(acct)
    assert(acct.valid?)
    assert(acct.reset_code.blank?)
    assert(acct.enabled?)
    assert(acct.password?('testme'))

    # make sure you can't reset now
    acct = Identity.reset_password!(pjones.user_name, code, 'foobar', 'foobar')
    assert_nil(acct)

    # test a reset, where you give a bad password
    pjones = identities(:pjones)
    code = pjones.reset_code!
    assert(pjones.save)
    acct = Identity.reset_password!(pjones.user_name, code, 'foobar', 'wtf')
    assert_not_nil(acct)
    assert(!acct.valid?)
  end

end
