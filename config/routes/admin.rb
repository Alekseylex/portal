# Пользователи
namespace :admin do
  namespace :users do
    get :index, path: '' # Главная страничка
    get :new
    post :create # создание поступления
    delete :delete # Удаление
  end
end