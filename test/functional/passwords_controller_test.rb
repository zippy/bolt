################################################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'passwords_controller'

################################################################################
# Re-raise errors caught by the controller.
class PasswordsController; def rescue_action(e) raise e end; end

################################################################################
class PasswordsControllerTest < Test::Unit::TestCase
  ################################################################################
  Engines::Testing.set_fixture_path
  fixtures(:identities, :users)

  ################################################################################
  def setup
    @controller = PasswordsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  ################################################################################
  def test_index_goes_to_new_when_logged_in
    get(:index, {}, {:user_id => users(:pjones).id})
    assert_response(:redirect)
    assert_redirected_to(:action => 'new')
  end
  
  ################################################################################
  def test_index_goes_to_forgot_when_not_logged_in
    get(:index)
    assert_response(:redirect)
    assert_redirected_to(:action => 'forgot')
  end
  
  ################################################################################
  def test_user_can_change_password
    user = users(:pjones)
    params = {:current => 'foobar', :password => 'foobaz', :confirmation => 'foobaz'}
    post(:create, params, {:user_id => user.id})
    assert_response(:redirect)
    identity = Identity.find(user.bolt_identity_id)
    assert(identity.password?('foobaz'))
  end

  ################################################################################
  def test_user_can_reset_password
    user = users(:pjones)
    identity = user.bolt_identity
    identity.reset_code!
    
    params = {
      :id           => identity.reset_code,
      :login        => user.email,
      :password     => 'foobaz',
      :confirmation => 'foobaz',
    }
    
    post(:update, params)
    assert_response(:redirect)
    assert_not_nil(session[:user_id])
    identity.reload
    assert(identity.reset_code.blank?)
    assert(identity.password?('foobaz'))
  end

  ################################################################################
  def test_requesting_reset_code
    user = users(:pjones)
    identity = user.bolt_identity
    assert(identity.reset_code.blank?)
    post(:forgot, :login => user.email)
    assert_response(:redirect)
    assert_redirected_to(:action => 'resetcode')
    identity.reload
    assert(!identity.blank?)
  end
  
end
