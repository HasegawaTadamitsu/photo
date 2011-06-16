Photo::Application.routes.draw do
#  root :to => "upload_files#index"
#  resources :upload_files, :only => [:index, :new, :create]

  root :to => "moshikomis#new"
  resources :moshikomis, :only => [ :new, :create]

  match "/moshikomis/:id" => "moshikomis#show"
  match "/moshikomis/pic/:id" => "moshikomis#show_pic"
  match "/moshikomis/complete/:id" => "moshikomis#complete"

end
