class Users::RegistrationsController < Devise::RegistrationsController
  
  layout "devise"

  before_action :check_authorization, :only => [:destroy]
  before_filter :find_categories

  def find_categories
    @categories = Category.is_parent
  end

  # before_filter :configure_sign_up_params, only: [:create]
  # before_filter :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    super
  end

  # POST /resource
  def create
    build_resource(sign_up_params)

    resource.save
    yield resource if block_given?

    if resource.persisted?

      if resource.active_for_authentication?
        # CREATE ACTIVE ACCOUNT with email == user.email
        account_was_created = create_an_associated_account resource

        if account_was_created
          set_flash_message :notice, :signed_up if is_flashing_format?
        else
          flash[:warning] = 'User has created, but user account has not created.'
        end

        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end

  end

  def create_an_associated_account(user)
    result = false

    # create user Account
    acc_params = account_params
    acc_params[:user_id] = user.id
    acc_params[:email] = user.email
    acc_params[:active] = true

    # group_id for account by group name
    group = Group.find_by_name(params[:account][:group_name])
    if group
      acc_params[:group_id] = group.id
    end

    account = Account.new(acc_params)
    result = true if account.save

    result
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  def account_params
    params.require(:account).permit(:name, :address_1, :address_2, :city, :state, :zip, :phone, :fax, :email, :group_name)
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.for(:sign_up) << :attribute
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.for(:account_update) << :attribute
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
  
  # before_filter :find_categories
  # before_filter :find_cart
  # 
  # def find_categories
  #   @categories = Category.is_parent
  # end
  # 
  # def find_cart
  #   puts "WERE HERE"
  #   if session[:cart_id].blank?
  #     if current_user
  #       session[:cart_id] = Cart.open.find_or_create_by(:account_id => current_user.account.id).id
  #     else
  #       session[:cart_id] = Cart.create.id
  #     end
  #   else
  #     if Cart.find_by(:id => session[:cart_id]).blank?
  #       puts "ITS NIL"
  #       session[:cart_id] = nil
  #       session[:cart_id] = Cart.create.id
  #     end
  #   end
  #   puts "......---->> #{session[:cart_id]}"
  #   @cart = Cart.find_by(:id => session[:cart_id])
  # end
  
end
