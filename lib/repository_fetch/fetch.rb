module RepositoryFetch

  def self.logger
    ::Rails.logger
  end

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

  def self.clone_or_fetch(repository)
    return unless repository.scm_name == "Git"

    path = repository.url

    p = PATTERNS.find { |p| path.starts_with? p[:pattern] }
    unless p
      # TODO: figure out how to handle non-matching repos.
      # eg. skip them, try fetching them, throw warning or not?
      proj = repository.project.identifier
      logger.warn "repository_fetch: no match for '#{path}' in project '#{proj}'"
      return
    end

    # If dir exists and non-empty, should be safe to 'git fetch'
    if Dir.exists?(path) && Dir.entries(path) != [".", ".."]
      puts "Running git fetch on #{path}"
      puts self.exec_with_key "git -C #{path} fetch --all", p[:key]
    else
      # try cloning the repo
      url = path.sub( p[:pattern], p[:uri_prefix])
      puts "Matched new URL, trying to clone: " + url
      puts self.exec_with_key "git clone --mirror #{url} #{path}", p[:key]
    end
  end

  def self.exec_with_key(cmd, keyfile)
    return `ssh-agent bash -c 'ssh-add #{keyfile}; #{cmd}'`
  end

  def self.fetch
    Project.active.has_module(:repository).all.each do |project|
      project.repositories.each do |repository|
        self.clone_or_fetch(repository)
      end
    end
  end

  class Fetcher
  end
end
