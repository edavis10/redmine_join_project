module JoinProject
  module Patches
    module ProjectPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.extend(ClassMethods)
        base.class_eval do
          validates_inclusion_of :project_subscription, :in => subscription_options, :allow_nil => true, :allow_blank => 'true'
        end
      end


      module ClassMethods
        def subscription_options
          ['none','self-subscribe','request']
        end

        def subscription_select_options
          [
           [l(:label_none),'none'],
           [l(:join_project_text_self_subscribe), 'self-subscribe'],
           [l(:join_project_text_request_to_join), 'request']
           ]
        end
      end
        
      module InstanceMethods
        def self_subscribe_allowed?
          project_subscription == 'self-subscribe'
        end

        def request_to_join?
          project_subscription == 'request'
        end
      end
    end
  end
end
