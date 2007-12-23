################################################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'passwords_controller'

################################################################################
# Re-raise errors caught by the controller.
class PasswordsController; def rescue_action(e) raise e end; end

################################################################################
class PasswordsControllerTest < Test::Unit::TestCase
  ################################################################################
  self.fixture_path = File.join(File.dirname(__FILE__), '..', 'fixtures')
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
  
end
