# frozen_string_literal: true
class UsersController < ApplicationController
  # before_action :set_user, only: [:show, :edit, :update, :destroy, :finish_signup, :profile_upload]
  # before_action :check_if_admin, except: [:update, :profile_upload]
  # before_action :modify_params, :only => [:update]
  # layout 'admin'

  def index
    @users = User.all
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html {redirect_to @user, notice: 'User was successfully created.'}
        format.json {render :show, status: :created, location: @user}
      else
        format.html {render :new}
        format.json {render json: @user.errors, status: :unprocessable_entity}
      end
    end
  end

  def update
    @user ||= current_user
    respond_to do |format|
      if @user.update(user_params)
        sign_in(@user, :bypass => true)
        format.html {redirect_to @user, notice: 'Your profile was successfully updated.'}
        format.json {respond_with_bip(@user)}
      else
        format.html {render action: 'edit'}
        format.json {respond_with_bip(@user)}
      end
    end
  end

  def finish_signup
    if request.patch? && params[:user] 
      if @user.update(user_params)
        sign_in(@user, :bypass => true)
        redirect_to @user, notice: 'Your profile was successfully updated.'
      else
        @show_errors = true
      end
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html {redirect_to users_url, notice: 'User was successfully destroyed.'}
      format.json {head :no_content}
    end
  end


  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    accessible = [:name, :email, :title, :company_name, :company_email, :first_name, :last_name, :is_admin, :phone_number,
                  :linkedIn_URL ,:are_terms_acknowledged, :is_industry_interest_collected]
    accessible << [:password, :password_confirmation] unless params[:user][:password].blank?
    params.require(:user).permit(accessible)
  end

  def check_if_admin
    if !current_user.is_admin
      redirect_to root_path
    end
  end

  def get_name(proper_name)
    proper_name.split.map(&:capitalize)
  end
end