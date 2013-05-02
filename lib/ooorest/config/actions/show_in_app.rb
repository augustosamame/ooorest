module Ooorest
  module Config
    module Actions
      class ShowInApp < Ooorest::Config::Actions::Base
        Ooorest::Config::Actions.register(self)

        register_instance_option :member do
          true
        end

        register_instance_option :visible? do
          authorized? && (bindings[:controller].main_app.url_for(bindings[:object]) rescue false)
        end

        register_instance_option :controller do
          Proc.new do
            redirect_to main_app.url_for(@object)
          end
        end

        register_instance_option :link_icon do
          'icon-eye-open'
        end

        register_instance_option :pjax? do
          false
        end
      end
    end
  end
end
