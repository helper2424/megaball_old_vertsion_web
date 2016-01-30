require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
 
module RailsAdminRefreshUser
end
 
module RailsAdmin
  module Config
    module Actions
      class RefreshUser < RailsAdmin::Config::Actions::Base
        register_instance_option :visible? do
          true
        end

        register_instance_option :link_icon do
          'icon-refresh'
        end

        register_instance_option :pjax? do
          true
        end

        register_instance_option :member? do
          true
        end

        register_instance_option :http_methods do
          [:get, :delete]
        end

        register_instance_option :controller do
          Proc.new do
            if request.get? # DELETE

              respond_to do |format|
                format.html { render @action.template_name }
                format.js   { render @action.template_name, layout: false }
              end

            elsif request.delete? # DESTROY
              is_admin = @object.admin
              oauth_provider = @object.oauth_providers.first

              if oauth_provider.nil?
                flash[:notice] = "User #{@object._id} does not have oauth_providers data, it's empty, cant delete it"
              else
                @object.oauth_providers = []
                @object.save

                new_user = User.find_for_provider_oauth oauth_provider.provider, {
                    uid: oauth_provider.uid, 
                    info: {},
                    zone: @object.zone,
                    locale: @object.locale
                  }, nil

                new_user.admin = is_admin
                new_user.save

                #@object.update_attribute(:approved, true)
                flash[:notice] = "User refreshed, new id #{new_user._id}"
              end
           
              redirect_to index_path
            end
          end
        end
      end
    end
  end
end