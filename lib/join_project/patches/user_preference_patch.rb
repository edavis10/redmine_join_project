module JoinProject
  module Patches
    module UserPreferencePatch
      def self.included(base)
        base.send(:include, InstanceMethods)
      end
        
      module InstanceMethods
        def block_join_project_requests
          self[:block_join_project_requests]
        end

        def block_join_project_requests=(value)
          self[:block_join_project_requests]=value
        end
      end
    end
  end
end
