Rails.application.routes.draw do

  scope 'projects/:project_id' do
    resource :issue_templates_settings, only: :update

    resources :issue_templates, as: :project_issue_templates do
      member do
        get :load
      end
      collection do
        get :set_pulldown
        get :list
      end
    end
  end

  resources :global_issue_templates
  resources :issue_template_previews, only: :create
end
