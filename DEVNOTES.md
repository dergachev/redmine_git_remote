## Dev Notes

### TODOs

* integrate webhook support (callback to accept POST, figure out repo, run git fetch on it), check security / DOS
* key management (currently user needs to populate ~/.ssh/* config files manually)
* cleanup cloned repos on Repository#destroy
* make sure git fetch doesn't hang (timeout, background, local vs remote fetch interference)
* last fetched status, clearer error handling
* on plugin uninstall, Redmine will crash (rails hates it when you remove model classes)
* (provide a rake command to convert to Git type)
* initialize_clone should only run on new objects (since only "Main repository" is editable)
* key handling
* removing the plugin, what happens to records?
* conversion of legacy records


### Testing

Figure out how to test this plugin!

* circle CI for integration tests?
* docker container with this plugin installed
* create a dummy project, create a repo record for http://github.com/dergachev/redmine_git_remote.git
* repositories_git_controller_test.rb and repositories_git_test.rb

### Misc snippets

Here's some bash commands I was pasting in regularly while working on this.

```
cd /home/redmine/redmine && ./script/rails runner "Repository.fetch_changesets" -e production
cd /home/redmine/redmine/; bundle exec rails console production
bundle exec rails dbconsole production

# config.consider_all_requests_local = true
apt-get update; apt-get install vim -y; vim /home/redmine/redmine/config/environments/production.rb

# useful under https://github.com/dergachev/docker-redmine
rsync -avq --chown=redmine:redmine /home/redmine/data/plugins/ /home/redmine/redmine/plugins/; supervisorctl restart unicorn

```
