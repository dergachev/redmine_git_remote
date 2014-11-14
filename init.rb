require 'redmine'
require_dependency "repository_fetch/fetch"

Redmine::Plugin.register :repository_fetch do
  name 'Repository Fetch'
  author 'Alex Dergachev'
  url 'https://github.com/dergachev/redmine_repository_fetch'
  description 'Automatically clone and fetch referenced repositories'
  version '0.0.1'
end
