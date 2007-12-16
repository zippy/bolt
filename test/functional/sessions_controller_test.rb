################################################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'rauth/sessions_controller'

################################################################################
# Re-raise errors caught by the controller.
class SessionsController; def rescue_action(e) raise e end; end

################################################################################
class SessionsControllerTest < Test::Unit::TestCase

  ################################################################################
  def setup
    @controller = SessionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  ################################################################################
  def test_failed_login
    post(:create, :username => 'foo', :password => 'foo')
    assert_response(:success) # make sure we weren't redirected
    assert_nil(session[:user_id])
  end

end
