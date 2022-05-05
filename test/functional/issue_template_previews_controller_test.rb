require File.expand_path('../../test_helper', __FILE__)

class IssueTemplatePreviewsControllerTest < ActionController::TestCase
  fixtures :users

  setup do
    @request.session[:user_id] = 2
  end

  test "should render template preview" do
    post :create, params: { template: { description: '**bar**'} }
    assert_response :success
    assert_select 'p b', 'bar'
  end

  test "should render help preview" do
    post :create, params: { settings: { help_message: '**bar**'} }
    assert_response :success
    assert_select 'p b', 'bar'
  end

  test "should render nothing preview" do
    post :create
    assert_response :success
    assert_select 'p.empty-preview'
  end
end
