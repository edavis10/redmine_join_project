module JoinProject
  module Hooks
    class MyHooks < Redmine::Hook::ViewListener
      # :user
      # :form
      def view_my_account(context={})
        return context[:controller].send(:render_to_string, :partial => 'join_projects/my_account_notifications', :locals => {:user => context[:user], :form => context[:form]})
      end
    end
  end
end
