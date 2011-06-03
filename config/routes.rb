Photo::Application.routes.draw do
  root :to => "upload_files#index"
  resources :upload_files, :only => [:index, :new, :create]
  match "/upload_files/:id" => "upload_files#show"
  match "/upload_files/pic/:id" => "upload_files#show_pic"
  match "/upload_files/complete/:id" => "upload_files#complete"

end
