require File.expand_path('../test_helper', __dir__)

class IssueTemplatePreviewsControllerTest < ActionController::TestCase
  fixtures :users

  setup do
    @request.session[:user_id] = 2
  end

  test "should render template preview" do
    post :create, template: { description: '**bar**'}
    assert_response :success
    assert_select 'fieldset.preview p b', 'bar'
  end

  test "should render help preview" do
    post :create, settings: { help_message: '**bar**'}
    assert_response :success
    assert_select 'fieldset.preview p b', 'bar'
  end

  test "should render nothing preview" do
    post :create
    assert_response :success
    assert_select 'fieldset.preview'
  end
end
