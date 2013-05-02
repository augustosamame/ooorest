module Ooorest
  module Config
    module Actions
      class HistoryShow < Ooorest::Config::Actions::Base
        Ooorest::Config::Actions.register(self)

        register_instance_option :authorization_key do
          :history
        end

        register_instance_option :member do
          true
        end

        register_instance_option :route_fragment do
          'history'
        end

        register_instance_option :controller do
          Proc.new do
            @general = false
            @history = @auditing_adapter && @auditing_adapter.listing_for_object(@abstract_model, @object, params[:query], params[:sort], params[:sort_reverse], params[:all], params[:page]) || []

            render @action.template_name
          end
        end

        register_instance_option :template_name do
          :history
        end

        register_instance_option :link_icon do
          'icon-book'
        end
      end
    end
  end
end
