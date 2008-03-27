################################################################################
require File.dirname(__FILE__) + '/../test_helper'

################################################################################
ActionController::Routing::Routes.draw do |map|
  map.instance_eval(File.read(File.dirname(__FILE__) + '/../../routes.rb'))
  map.connect ':controller/:action'
end

################################################################################
class HttpBasicTestController < ApplicationController
  require_authentication
  def rescue_action(e) raise e end
  def index () render(:text => 'hello') end
end

################################################################################
class HttpBasicTestControllerTest < Test::Unit::TestCase
  
  ################################################################################
  Engines::Testing.set_fixture_path
  fixtures(:identities, :users)

  ################################################################################
  def setup
    @controller = HttpBasicTestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  ################################################################################
  def test_index_requires_login
    get(:index)
    assert_response(:redirect)
  end
  
  ################################################################################
  def test_http_basic_login_success
    pjones = users(:pjones)
    @request.env['HTTP_AUTHORIZATION'] = 'Basic ' + ["#{pjones.email}:foobar"].pack("m*")
    get(:index)
    assert_response(:success)
    assert_not_nil(session[:user_id])
    assert_equal(pjones.id, session[:user_id])
  end
  
  ################################################################################
  def test_http_basic_login_failure
    pjones = users(:pjones)
    @request.env['HTTP_AUTHORIZATION'] = 'Basic ' + ["#{pjones.email}:bad"].pack("m*")
    get(:index)
    assert_response(:redirect)
    assert_nil(session[:user_id])
  end
  
end
