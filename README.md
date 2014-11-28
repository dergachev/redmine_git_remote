redmine_git_remote
==================

Redmine plugin to automatically clone and remote git repositories.

## Installation

Install the plugin as usual:

```
cd REDMINE_ROOT/plugins
git clone https://github.com/dergachev/redmine_git_remote
```

Then enable the new GitRemote SCM type in [http://redmine-root/settings?tab=repositories](http://redmine-root/settings?tab=repositories)

![](https://dl.dropbox.com/u/29440342/screenshots/AYKNZDTB-2014.11.27-15-59-06.png)

Be sure to install the appropriate SSH keys to `~/.ssh/id_rsa` (for your redmine user).
I recommend creating a [dedicated machine user](https://developer.github.com/guides/managing-deploy-keys/#machine-users) on github/gitlab for this purpose.

## Usage

This plugin defines a new repository type, GitRemote, which allows you to associate
a remote repository with your Redmine project. First create a new repository of type
GitRemote, enter the clone URL. The identifier and path will be auto-generated, but can be overriden.

![](https://dl.dropbox.com/u/29440342/screenshots/ATIAQXHG-2014.11.27-15-03-51.png)

On submitting the repository creation form, the identifier and `url`
(filesystem path) fields will be auto-generated (if not explicitly provided).

For example, if you enter `https://github.com/dergachev/vagrant-vbox-snapshot` as the Clone URL,
it will prefill the Identifier and filesystem path fields as follows:
* Identifier: `vagrant-vbox-snapshot`
* URL (filesystem path): `REDMINE_PLUGINS_PATH/redmine_git_remote/repos/github.com/dergachev/vagrant-vbox-snapshot`

Once the remote URL is validated, the plugin creates an [empty clone](http://stackoverflow.com/questions/895819/whats-the-most-straightforward-way-to-clone-an-empty-bare-git-repository) at the specified path.

This plugin hooks into the core `Repository.fetch_changesets` to automatically
run `git fetch --all` on all GitRemote managed repositories as Redmine is about
to pull in changesets from the local repos.

To avoid slowing down the GUI, we recommend unchecking the "Fetch commits
automatically" setting at
[http://redmine-root/settings?tab=repositories](http://redmine-root/settings?tab=repositories)
and relying on the following cron job as per [Redmine Wiki Instructions](http://www.redmine.org/projects/redmine/wiki/RedmineRepositories):

```
*/5 * * * * cd /home/redmine/redmine && ./script/rails runner \"Repository.fetch_changesets\" -e production >> log/cron_rake.log 2>&1
```

To trigger fetch manually, run this:

```
cd /home/redmine/redmine && ./script/rails runner "Repository.fetch_changesets" -e production
```

Note GitRemote doesn't delete the cloned repos when the associated record is deleted from Redmine.

Tested on Redmine 2.6.
