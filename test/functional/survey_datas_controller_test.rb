require 'test_helper'

class SurveyDatasControllerTest < ActionController::TestCase
  setup do
    @survey_data = survey_datas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:survey_datas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create survey_data" do
    assert_difference('SurveyData.count') do
      post :create, :survey_data => @survey_data.attributes
    end

    assert_redirected_to survey_data_path(assigns(:survey_data))
  end

  test "should show survey_data" do
    get :show, :id => @survey_data.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @survey_data.to_param
    assert_response :success
  end

  test "should update survey_data" do
    put :update, :id => @survey_data.to_param, :survey_data => @survey_data.attributes
    assert_redirected_to survey_data_path(assigns(:survey_data))
  end

  test "should destroy survey_data" do
    assert_difference('SurveyData.count', -1) do
      delete :destroy, :id => @survey_data.to_param
    end

    assert_redirected_to survey_datas_path
  end
end
