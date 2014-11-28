module RedmineGitRemote
  module RepositoriesHelperPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def git_remote_field_tags(form, repository)
        content_tag('p', form.text_field(:url,
                           :size => 60, :required => true, :required => false,
                           :disabled => !repository.safe_attribute?('url'),
                           :label => l(:field_path_to_repository)) +
                          content_tag('em', l(:text_git_remote_path_note), :class => 'info') +
                          form.text_field(:extra_clone_url, :size => 60, :required => true,
                           :disabled => !repository.safe_attribute?('url')) +
                          content_tag('em', l(:text_git_remote_url_note), :class => 'info')
                   )
      end
    end
  end

  RepositoriesHelper.send(:include, RepositoriesHelperPatch)
end
