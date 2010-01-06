module JoinProject
  module Patches
    module ProjectPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          validates_inclusion_of :project_subscription, :in => ['none','self-subscribe','request'], :allow_nil => true, :allow_blank => 'true'
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
