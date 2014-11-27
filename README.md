redmine_git_remote
==================

Redmine plugin to automatically clone and remote git repositories.

## Installation

Install the plugin as usual:

```
cd REDMINE_ROOT/plugins
git clone https://github.com/dergachev/redmine_git_remote
```

Be sure to install the appropriate SSH keys to `~/.ssh/id_rsa` (for your redmine user).
I recommend creating a dedicated deployment user on github/gitlab for this purpose.

## Usage

This plugin defines a new repository type, GitFetch, which allows you to associate
a remote repository with your Redmine project. First create a new repository of type
GitFetch, enter the clone URL. The identifier and path will be auto-generated, but can be overriden.

![](https://dl.dropbox.com/u/29440342/screenshots/ATIAQXHG-2014.11.27-15-03-51.png)

On submitting the repository creation form, the identifier and `url`
(filesystem path) fields will be auto-generated (if not explicitly provided) as follows:

Clone URL: `https://github.com/dergachev/vagrant-vbox-snapshot`
URL (filesystem path): `REDMINE_PLUGINS_PATH/redmine_git_remote/repos/github.com/dergachev/vagrant-vbox-snapshot`
Identifier: `vagrant-vbox-snapshot`

Once the remote URL is validated, the plugin creates an "empty clone" at the specified path.

This plugin hooks into the core `Repository.fetch_changesets` to automatically
run `git fetch --all` on all GitRemote managed repositories, before those
commits are imported into Redmine. To avoid slowing down the GUI, we recommend
unchecking the "Fetch commits automatically" setting at
[http://redmine-root/settings?tab=repositories](http://redmine-root/settings?tab=repositories)
and relying on the following cron job as per [Redmine Wiki Instructions](http://www.redmine.org/projects/redmine/wiki/RedmineRepositories):

```
cd /home/redmine/redmine && ./script/rails runner \"Repository.fetch_changesets\" -e production >> log/cron_rake.log 2>&1
```

Note GitRemote doesn't delete the cloned repos when the associated record is deleted from Redmine.

Tested on Redmine 2.6.
