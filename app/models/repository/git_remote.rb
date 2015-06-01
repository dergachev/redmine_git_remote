require 'redmine/scm/adapters/git_adapter'
require 'pathname'
require 'fileutils'
# require 'open3'
require_dependency 'redmine_git_remote/poor_mans_capture3'

class Repository::GitRemote < Repository::Git

  PLUGIN_ROOT = Pathname.new(__FILE__).join("../../../..").realpath.to_s
  PATH_PREFIX = PLUGIN_ROOT + "/repos/"

  before_validation :initialize_clone

  # TODO: figure out how to do this safely (if at all)
  # before_deletion :rm_removed_repo
  # def rm_removed_repo
  #   if Repository.find_all_by_url(repo.url).length <= 1
  #     system "rm -Rf #{self.clone_path}"
  #   end
  # end

  def extra_clone_url
    return nil unless extra_info
    extra_info["extra_clone_url"]
  end

  def clone_url
    self.extra_clone_url
  end

  def clone_path
    self.url
  end

  def clone_host
    p = parse(clone_url)
    return p[:host]
  end

  def clone_protocol_ssh?
    # Possible valid values (via http://git-scm.com/book/ch4-1.html):
    #  ssh://user@server/project.git
    #  user@server:project.git
    #  server:project.git
    # For simplicity we just assume if it's not HTTP(S), then it's SSH.
    !clone_url.match(/^http/)
  end

  # Hook into Repository.fetch_changesets to also run 'git fetch'.
  def fetch_changesets
    # ensure we don't fetch twice during the same request
    return if @already_fetched
    @already_fetched = true

    puts "Calling fetch changesets on #{clone_path}"
    # runs git fetch
    self.fetch
    super
  end

  # Override default_branch to fetch, otherwise caching problems in
  # find_project_repository prevent Repository::Git#fetch_changesets from running.
  #
  # Ideally this would only be run for RepositoriesController#show.
  def default_branch
    if self.branches == [] && self.project.active? && Setting.autofetch_changesets?
      # git_adapter#branches caches @branches incorrectly, reset it
      scm.instance_variable_set :@branches, nil
      # NB: fetch_changesets is idemptotent during a given request, so OK to call it 2x
      self.fetch_changesets
    end
    super
  end

  # called in before_validate handler, sets form errors
  def initialize_clone
    # avoids crash in RepositoriesController#destroy
    return unless attributes["extra_info"]["extra_clone_url"]

    p = parse(attributes["extra_info"]["extra_clone_url"])
    self.identifier = p[:identifier] if identifier.empty?
    self.url = PATH_PREFIX + p[:path] if url.empty?

    err = ensure_possibly_empty_clone_exists
    errors.add :extra_clone_url, err if err
  end

  # equality check ignoring trailing whitespace and slashes
  def two_remotes_equal(a,b)
    a.chomp.gsub(/\/$/,'') == b.chomp.gsub(/\/$/,'')
  end

  def ensure_possibly_empty_clone_exists
    Repository::GitRemote.add_known_host(clone_host) if clone_protocol_ssh?

    unless system "git", "ls-remote",  "-h",  clone_url
      return "#{clone_url} is not a valid remote."
    end

    if Dir.exists? clone_path
      existing_repo_remote, status = RedmineGitRemote::PoorMansCapture3::capture2("git", "--git-dir", clone_path, "config", "--get", "remote.origin.url")
      return "Unable to run: git --git-dir #{clone_path} config --get remote.origin.url" unless status.success?

      unless two_remotes_equal(existing_repo_remote, clone_url)
        return "Directory '#{clone_path}' already exits, unmatching clone url: #{existing_repo_remote}"
      end
    else
      unless system "git", "init", "--bare", clone_path
        return  "Unable to run: git init --bare #{clone_path}"
      end

      unless system "git", "--git-dir", clone_path, "remote", "add", "--mirror=fetch", "origin",  clone_url
        return  "Unable to run: git --git-dir #{clone_path} remote add --mirror=fetch origin #{clone_url}"
      end
    end
  end

  unloadable
  def self.scm_name
    'GitRemote'
  end

  # TODO: first validate git URL and display error message
  def parse(url)
    url.strip!

    ret = {}
    # start with http://github.com/evolvingweb/git_remote or git@git.ewdev.ca:some/repo.git
    ret[:url] = url

    # NB: Starting lines with ".gsub" is a syntax error in ruby 1.8.
    #     See http://stackoverflow.com/q/12906048/9621
    # path is github.com/evolvingweb/muhc-ci
    ret[:path] = url.gsub(/^.*:\/\//, '').   # Remove anything before ://
                     gsub(/:/, '/').         # convert ":" to "/"
                     gsub(/^.*@/, '').       # Remove anything before @
                     gsub(/\.git$/, '')      # Remove trailing .git
    ret[:host] = ret[:path].split('/').first
    #TODO: handle project uniqueness automatically or prompt
    ret[:identifier] =   ret[:path].split('/').last.downcase.gsub(/[^a-z0-9_-]/,'-')
    return ret
  end

  def fetch
    puts "Fetching repo #{clone_path}"
    Repository::GitRemote.add_known_host(clone_host) if clone_protocol_ssh?

    err = ensure_possibly_empty_clone_exists
    Rails.logger.warn err if err

    # If dir exists and non-empty, should be safe to 'git fetch'
    unless system "git", "--git-dir", clone_path, "fetch", "--all"
      Rails.logger.warn "Unable to run 'git -c #{clone_path} fetch --all'"
    end
  end

  # Checks if host is in ~/.ssh/known_hosts, adds it if not present
  def self.add_known_host(host)
    # if not found...
    out, status = RedmineGitRemote::PoorMansCapture3::capture2("ssh-keygen", "-F", host)
    raise "Unable to run 'ssh-keygen -F #{host}" unless status
    unless out.match /found/
      # hack to work with 'docker exec' where HOME isn't set (or set to /)
      ssh_dir = (ENV['HOME'] == "/" || ENV['HOME'] == nil ? "/root" : ENV['HOME']) + "/.ssh"
      ssh_known_hosts = ssh_dir + "/known_hosts"
      begin
        FileUtils.mkdir_p ssh_dir
      rescue Exception => e
        raise "Unable to create directory #{ssh_dir}: " + e.to_s
      end

      puts "Adding #{host} to #{ssh_known_hosts}"
      out, status = RedmineGitRemote::PoorMansCapture3::capture2("ssh-keyscan", host)
      raise "Unable to run 'ssh-keyscan #{host}'" unless status
      Kernel::open(ssh_known_hosts, 'a') { |f| f.puts out}
    end
  end
end
