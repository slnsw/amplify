class Admin::UsersController < AdminController
  before_action :set_user, only: [:update, :destroy]
  before_action :load_collections, only: [:index, :destroy]

  def index
    authorize User
  end

  # PATCH/PUT /admin/users/{id}.json
  def update
    authorize User

    if @user.update(user_params)
      head :no_content
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /admin/users/{id}.json
  def destroy
    authorize User

    if @user.delete
      head :no_content
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private

  def load_collections
    @users = policy_scope(User).
      only_public_users.order("lines_edited DESC").
      paginate(page: params[:page], per_page: params[:per_page])
    @staff = policy_scope(User).only_staff_users.orderByInstitution.decorate
    @user_roles = policy_scope(UserRole).getAll
    @institutions = policy_scope(Institution).all
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:user_role_id, :institution_id)
  end
end
