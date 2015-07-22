Rails.application.routes.draw do

  scope '/projects/:project_id', :as => 'project' do
    resources :issue_templates do
      member do
        put :move_to_top, :move_higher, :move_lower, :move_to_bottom
      end
      collection do
        post :preview
        get :set_pulldown, :load
      end
    end

    resource :issue_templates_settings, only: :update do
      collection { post :preview }
    end
  end

  resources :global_issue_templates do
    member do
      put :move_to_top, :move_higher, :move_lower, :move_to_bottom
    end
    collection { post :preview }
  end

end

