module RedmineGitRemote
  module RepositoriesHelperPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def git_remote_field_tags(form, repository)
        local_path_tag = form.text_field(:url,
                                         :size => 60, :required => false,
                                         :disabled => !repository.safe_attribute?('url'),
                                         :label => l(:field_path_to_repository))
        local_path_note = content_tag('em', l(:text_git_remote_path_note), :class => 'info')

        remote_url_prefix = Setting.plugin_redmine_git_remote["git_remote_url_prefix_default"].presence || ''

        remote_url_tag = form.text_field(:extra_clone_url, :size => 60, :required => true,
                                         :value => remote_url_prefix,
                                         :disabled => !repository.safe_attribute?('url'))
        remote_url_note = content_tag('em', l(:text_git_remote_url_note), :class => 'info')

        git_remote_tag = content_tag('p',  local_path_tag + local_path_note + remote_url_tag + remote_url_note)

        git_remote_tag
      end
    end
  end

  RepositoriesHelper.send(:include, RepositoriesHelperPatch)
end
