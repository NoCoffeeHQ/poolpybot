# frozen_string_literal: true

Rails.application.routes.draw do
  # Authentication
  get 'sign_up', to: 'authentication/sign_up#new', as: :new_sign_up
  post 'sign_up', to: 'authentication/sign_up#create', as: :sign_up

  get sign_in: 'authentication/sign_in#new', as: :new_sign_in
  post sign_in: 'authentication/sign_in#create', as: :sign_in
  post sign_out: 'authentication/sign_in#destroy', as: :sign_out

  # Routes when logged in
  get 'dashboard', to: 'dashboard#index', as: :dashboard

  # Defines the root path route ("/")
  root 'home#index'
end
