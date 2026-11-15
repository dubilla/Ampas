class Users::SessionsController < Devise::SessionsController
  def new
    self.resource = resource_class.new(sign_in_params)
    store_location_for(resource, params[:redirect_to]) if local_path?(params[:redirect_to])
    super
  end

  private

  def local_path?(path)
    path.is_a?(String) && path.start_with?('/') && !path.start_with?('//', '/\\')
  end
end
