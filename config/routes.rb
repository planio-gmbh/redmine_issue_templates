Rails.application.routes.draw do
  get 'projects/:project_id/issue_templates', :to => 'issue_templates#index'
  match 'projects/:project_id/issue_templates/:action', :to => 'issue_templates', :via => [:get, :post, :patch, :put]
  match 'projects/:project_id/issue_templates/:action/:id', :to => 'issue_templates#edit' ,:via => [:patch, :put, :post, :get]
  match 'projects/:project_id/issue_templates/move/:id', :to => 'issue_templates#move_to', :via => [:get, :post, :patch, :put]
  match 'projects/:project_id/issue_templates_settings/:action', :to => 'issue_templates_settings', :via => [:get, :post, :patch, :put]
  match 'issue_templates/preview', :to => 'issue_templates#preview', :via => [:get, :post]
  match 'projects/:project_id/issue_templates_settings/preview', :to => 'issue_templates_settings#preview', :via => [:get, :post]
  get 'global_issue_templates', :to => 'global_issue_templates#index'
  match 'global_issue_templates/:action', :to => 'global_issue_templates', :via => [:get, :post]
  match 'global_issue_templates/:action/:id', :to => 'global_issue_templates#edit' ,:via => [:patch, :put, :post, :get]
  match 'global_issue_templates/preview', :to => 'global_issue_templates#preview', :via => [:get, :post]
end