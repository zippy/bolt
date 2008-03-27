################################################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'sessions_controller'

################################################################################
# Re-raise errors caught by the controller.
class SessionsController; def rescue_action(e) raise e end; end

################################################################################
class SessionsControllerTest < Test::Unit::TestCase
  ################################################################################
  Engines::Testing.set_fixture_path
  fixtures(:identities, :users)

  ################################################################################
  def setup
    @controller = SessionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  ################################################################################
  def test_failed_login
    post(:create, :login => 'foo', :password => 'foo')
    assert_response(:success) # make sure we weren't redirected
    assert_nil(session[:user_id])
  end

  ################################################################################
  def test_successful_login
    pjones = users(:pjones)
    post(:create, :login => pjones.email, :password => 'foobar')
    assert_response(:redirect)
    assert_not_nil(session[:user_id])
    assert_equal(pjones.id, session[:user_id])
  end
  
end
