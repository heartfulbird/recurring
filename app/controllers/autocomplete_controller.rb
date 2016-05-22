class AutocompleteController < ApplicationController

  skip_before_filter :check_authorization, only: [:groups]

  # for example for sign up when we need groups autocomplete and user has not signed in yet
  def groups
    @groups = Group.order("name asc")
    unless params[:term].blank?
      @groups = @groups.lookup(params[:term]) if params[:term].present?
    end
    respond_to do |format|
      format.json {render :json => @groups.map(&:name)}
    end
  end

end