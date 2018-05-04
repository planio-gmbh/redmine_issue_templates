#
# TODO: Clean up routing.
#
Rails.application.routes.draw do
  get 'projects/:project_id/issue_templates', to: 'issue_templates#index'
  match 'projects/:project_id/issue_templates/new', to: 'issue_templates#new', via: [:post, :get]
  match 'projects/:project_id/issue_templates/:action', controller: 'issue_templates', via: [:patch, :put, :post, :get]
  match 'projects/:project_id/issue_templates/:action/:id', to: 'issue_templates#edit', via: [:patch, :put, :post, :get]
  match 'issue_templates/preview', to: 'issue_templates#preview', via: [:get, :post]
  match 'projects/:project_id/issue_templates_settings/preview', to: 'issue_templates_settings#preview', via: [:get, :post]
  get 'global_issue_templates', to: 'global_issue_templates#index'
  match 'global_issue_templates/:action', controller: 'global_issue_templates', via: [:get, :post]
  match 'global_issue_templates/:action/:id', to: 'global_issue_templates#edit', via: [:patch, :put, :post, :get]
  match 'global_issue_templates/preview', to: 'global_issue_templates#preview', via: [:get, :post]
  get 'projects/:project_id/issue_templates/orphaned_templates', to: 'issue_templates#orphaned_templates', as: 'project_orphaned_templates'
  get 'global_issue_templates/orphaned_templates', to: 'global_issue_templates#orphaned_templates', as: 'global_orphaned_templates'

  scope 'projects/:project_id' do
    resource :issue_templates_settings, only: :update
    resources :issue_templates, only: :new
  end

end
