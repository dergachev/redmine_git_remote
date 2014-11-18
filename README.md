redmine_repository_fetch
========================

Redmine plugin to automatically clone and fetch referenced repositories.

## Installation

Currently the plugin hardcodes this config, change it for your use-case:

```
   PATTERNS = [
     {  :pattern => "/redmine_git_fetch/github.com/",
        :uri_prefix => "git@github.com:",
        :host => "github.com",
        :key => "/home/redmine/data/keys/id_rsa"
     },
     {  :pattern => "/redmine_git_fetch/gitlab.com/",
        :uri_prefix => "git@gitlab.com:",
        :host => "gitlab.com",
        :key => "/home/redmine/data/keys/id_rsa"
     },
     {  :pattern => "/redmine_git_fetch/git.ewdev.ca/",
        :uri_prefix => "git@git.ewdev.ca:",
        :host => "git.ewdev.ca",
        :key => "/home/redmine/data/keys/id_rsa"
     }
   ]
```

Be sure to populate the appropriate keys for your redmine user (www-data, redmine, etc),
either in `~/.ssh` or in the place specified by the `PATTERNS[x][:key]` property.

## Usage

Add `/redmine_git_fetch/github.com/evolvingweb/sitediff.git` to a repo.  The
plugin will automatically detect the prefix `/redmine_git_fetch/github.com/`
and figure out it needs to clone `git@github.com:evolvingweb/sitediff.git`.
If it's already cloned it will fetch instead. In all cases you need to specify
a path to a private key to use, since all clones happen over SSH.

Note that `/redmine_git_fetch` folder will get auto-created.

The plugin currently doesn't fetch any repos outside its purview.

It also needs to be run as follows, probably from cron:

```
bundle exec rails runner "RepositoryFetch.fetch" -e production
```

Tested on Redmine 2.6.
