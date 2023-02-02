
Redmine::Scm::Base.add "GitRemote"

Redmine::Plugin.register :redmine_git_remote do
  name 'Redmine Git Remote'
  author 'Alex Dergachev'
  url 'https://github.com/dergachev/redmine_git_remote'
  description 'Automatically clone and fetch remote git repositories'
  version '0.0.2'
  
  requires_redmine version_or_higher: '5.0.0'
  
  settings partial: 'settings/git_remote_settings',
		   default: {
			'git_remote_repo_clone_path' => Pathname.new(__FILE__).join("../").realpath.to_s + "/repos"
		   }
  
end

unless Redmine::Plugin.installed?(:easy_extensions)
  require_relative 'after_init'
end