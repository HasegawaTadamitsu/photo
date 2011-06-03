Photo::Application.routes.draw do
  root :to => "upload_files#index"
  resources :upload_files, :only => [:index, :new,:create]
  match "/upload_files/:id" => "upload_files#show"
end
