Photo::Application.routes.draw do
  root :to => "upload_files#index"
  resources :upload_files

end
