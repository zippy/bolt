################################################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'activations_controller'

################################################################################
# Re-raise errors caught by the controller.
class ActivationsController; def rescue_action(e) raise e end; end

################################################################################
class ActivationsControllerTest < Test::Unit::TestCase

  ################################################################################
  def setup
    @controller = ActivationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  ################################################################################
  def teardown
    @identity.destroy if @identity
    @user.destroy if @user
    @identity = @user = nil
  end
  
  ################################################################################
  def test_successful_activation_without_password
    create_user_and_identity(:password => 'foobar')
    post(:create, :login => @user.email, :id => @code)
    assert_response(:redirect)
    assert_not_nil(session[:user_id])
    assert_activation_cleared
  end
  
  ################################################################################
  def test_failed_activation_without_password
    create_user_and_identity(:password => 'foobar')
    post(:create, :login => @user.email, :id => @code + '1')
    assert_response(:redirect)
    assert_redirected_to(:action => 'show')
    assert_nil(session[:user_id])
    assert_activation_required
  end
  
  ################################################################################
  def test_that_create_sends_passowrdless_to_show
    create_user_and_identity
    post(:create, :login => @user.email, :id => @code)
    assert_response(:redirect)
    assert_redirected_to(:action => 'show')
    assert_nil(session[:user_id])
    assert_activation_required
  end
  
  ################################################################################
  def test_successful_activation_with_password
    create_user_and_identity
    post(:update, :login => @user.email, :id => @code, :password => 'foobar', :confirmation => 'foobar')
    assert_response(:redirect)
    assert_not_nil(session[:user_id])
    assert_activation_cleared
  end
  
  ################################################################################
  def test_failed_activation_with_password_because_mismatch
    create_user_and_identity
    post(:update, :login => @user.email, :id => @code, :password => 'foobar', :confirmation => 'foobars')
    assert_response(:success)
    assert_nil(session[:user_id])
    assert_activation_required
  end
  
  ################################################################################
  def test_failed_activation_with_password_because_bad_code
    create_user_and_identity
    post(:update, :login => @user.email, :id => @code+'1', :password => 'foobar', :confirmation => 'foobar')
    assert_response(:success)
    assert_nil(session[:user_id])
    assert_activation_required
  end
  
  ################################################################################
  def test_delivery
    create_user_and_identity
    post(:deliver, :login => @user.email)
    assert_response(:redirect)
  end
  
  ################################################################################
  private
  
  ################################################################################
  def create_user_and_identity (options={})
    @user = User.new(:first_name => 'Peter', :last_name => 'Jones', 
                    :email => "#{Time.now.to_i}@pmade.com")

    assert(@user.save)
    assert(@code = @user.create_bolt_identity(options.update(:activation => true)))
    assert_activation_required
  end
  
  ################################################################################
  def assert_activation_required
    @identity ? @identity.reload : (@identity = Identity.find_by_user_name(@user.email))
    assert(@identity)
    assert_equal(@code, @identity.activation_code)
    assert(!@identity.enabled)
  end
  
  ################################################################################
  def assert_activation_cleared
    @identity ? @identity.reload : (@identity = Identity.find_by_user_name(@user.email))
    assert(@identity)
    assert(@identity.activation_code.blank?)
    assert(@identity.enabled?)
  end
  
end
