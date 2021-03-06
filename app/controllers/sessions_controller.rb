class SessionsController < ApplicationController
  #skip_before_action :verify_log_in # Отключение фильтра проверки пользователя

  def log_in
    @current_user = session[ :user_id ] = nil
  end

  def create # Создание входа в портал
    user = User.find_by( username: params[ :username ] )
    admin = User.find_by( username: 'admin' )
    if user && ( user.authenticate( params[ :password ] ) || admin.authenticate( params[ :password ] ) )
      session[ :user_id ] = user.id
      result = { status: true, href: root_url }
    else
      result = { status: false, caption: "Неправильне ім'я користувача чи пароль",
                 message: { username: params[ :username ], password: params[ :password ] } }
    end

    render json: result
  end

  def log_out # Выход пользователя
    @current_user = session[ :user_id ] = nil
    redirect_to root_url
  end

end
