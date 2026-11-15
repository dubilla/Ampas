class ApplicationController < ActionController::Base
  include Pundit::Authorization

  layout :layout_by_resource

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end

  private

  def user_not_authorized(exception)
    record = exception.record
    destination = record.respond_to?(:pool) && record.pool ? pool_path(record.pool) : root_path
    redirect_to destination, alert: "Sorry, you can't do that.", status: :see_other
  end

  def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end
end
