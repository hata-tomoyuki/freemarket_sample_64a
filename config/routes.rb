Rails.application.routes.draw do

  root to: 'posts#toppage'
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  } 

  devise_scope :user do
    
  end

  resources :mypage, only: [:index]
  resources :logout, only: [:index]
  resources :purchases, only: [:index]
  resources :products, only: [:new]
  # 動作確認用URL（サーバーサイド情報がまだないため仮ルート設定）
  get "/pruducts/1", to: 'products#show'
  resources :signup, only: [:index]
  resources :credit_card, only: [:new] do
    collection do
      post 'registration'
      post 'buy'
      post 'delete'
    end
  end

  resources :complete, only: [:index]
  resources :credit_card, only: [:index] do

  end
  resources :address, only: [:index, :edit] do
  end
end
