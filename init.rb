require 'redmine'
require_dependency "redmine_git_remote/repositories_helper_patch"

Redmine::Scm::Base.add "GitRemote"

Redmine::Plugin.register :redmine_git_remote do
  name 'Redmine Git Remote'
  author 'Alex Dergachev'
  url 'https://github.com/dergachev/redmine_git_remote'
  description 'Automatically clone and fetch remote git repositories'
  version '0.0.2'

  PLUGIN_ROOT = Pathname.new(__FILE__).join("..").realpath.to_s
  options = YAML::load( File.open(File.join(PLUGIN_ROOT + '/config', 'settings.yml')))

  settings :default => {'git_local_path_default' => options['git_local_path'],
                        'git_remote_url_prefix_default' => options['git_remote_url_prefix']},
                        :partial => 'settings/redmine_git_remote'
end
