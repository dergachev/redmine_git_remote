require 'redmine'

# TODO: why isn't this autoloaded? 
# NB: at this point, $PATH only contains {PLUGINS}/lib and app/models, app/controllers
#     but not {PLUGINS}/app/models. Maybe those get added later?
require File.dirname(__FILE__) + '/app/models/repository/git_fetch'

require_dependency "repository_fetch/repositories_helper_patch"

Redmine::Scm::Base.add "GitFetch"

Redmine::Plugin.register :redmine_repository_fetch do
  name 'Repository Fetch'
  author 'Alex Dergachev'
  url 'https://github.com/dergachev/redmine_repository_fetch'
  description 'Automatically clone and fetch referenced repositories'
  version '0.0.1'
end

