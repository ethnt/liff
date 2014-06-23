Rails.application.routes.draw do
  root 'liff#index'

  devise_for :users

  devise_scope :user do
    get '/login'   => 'devise/sessions#new'
    get '/logout'  => 'devise/sessions#destroy'

    get '/join'    => 'devise/registrations#new'
    get '/account' => 'devise/registrations#edit'
  end

  get '/:username(/:year/:month/:day)', to: 'users#show', as: 'user'

  get '/services/:service/link',    to: 'services#link', as: 'service_link'
  get '/services/:service/connect', to: 'services#connect', as: 'service_connect'
end
