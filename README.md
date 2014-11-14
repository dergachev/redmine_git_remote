redmine_repository_fetch
========================

Redmine plugin to automatically clone and fetch referenced repositories

Currently the plugin hardcodes this config, change it for your use-case:

```
   PATTERNS = [ 
     {  :pattern => "/redmine_git_fetch/github.com/",
        :uri_prefix => "git@github.com:",
        :key => "/home/redmine/data/keys/id_rsa"
     },
     {  :pattern => "/redmine_git_fetch/gitlab.com/",
        :uri_prefix => "git@gitlab.com:",
        :key => "/home/redmine/data/keys/id_rsa"
     },
     {  :pattern => "/redmine_git_fetch/git.ewdev.ca/",
        :uri_prefix => "git@git.ewdev.ca:",
        :key => "/home/redmine/data/keys/id_rsa"
     }
   ]
```

Once you have it setup, do the following:

Add `/redmine_git_fetch/github.com/evolvingweb/sitediff.git` to a repo.  The
plugin will automatically detect the prefix `/redmine_git_fetch/github.com/`
and figure out it needs to clone `git@github.com:evolvingweb/sitediff.git`.
If it's already cloned it will fetch instead. In all cases you need to specify
a path to a private key to use, since all clones happen over SSH.

Note that `/redmine_git_fetch` folder will get auto-created.

The plugin currently doesn't fetch any repos outside its purview.

It also needs to be run as follows:

```
bundle exec rails runner "RepositoryFetch.fetch" -e production
```

Tested on Redmine 2.6.
