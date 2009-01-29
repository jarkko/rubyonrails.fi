require 'mongrel_cluster/recipes'

# This defines a deployment "recipe" that you can feed to switchtower
# (http://manuals.rubyonrails.com/read/book/17). It allows you to automate
# (among other things) the deployment of your application.

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================
# You must always specify the application and repository for every recipe. The
# repository must be the URL of the repository you want this recipe to
# correspond to. The deploy_to path must be the path on each machine that will
# form the root of the application path.

set :application, "rubyonrails.fi"

set :repository,          "git@github.com:jarkko/rubyonrails.fi.git"
set :repository_cache,    "git_cache"
set :deploy_via,          :remote_cache
set :scm,                 :git
set :use_sudo,      false

# =============================================================================
# RAILS VERSION
# =============================================================================
# Use this to freeze your deployment to a specific rails version.  Uses the rake
# init task run in after_symlink below.

set :rails_version, 4928

# TODO: test this works and I can remove the restart task and use the cleanup task
# set :use_sudo, false

# =============================================================================
# ROLES
# =============================================================================
# You can define any number of roles, each of which contains any number of
# machines. Roles might include such things as :web, or :app, or :db, defining
# what the purpose of each machine is. You can also specify options that can
# be used to single out a specific subset of boxes in a particular role, like
# :primary => true.

role :web, "jlaine.net"
role :app, "jlaine.net"
role :db,  "jlaine.net", :primary => true

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
set :deploy_to, "/home/jarkko/sites/#{application}" # defaults to "/u/apps/#{application}"
# set :user, "flippy"            # defaults to the currently logged in user
# set :scm, :darcs               # defaults to :subversion
# set :svn, "/path/to/svn"       # defaults to searching the PATH
# set :darcs, "/path/to/darcs"   # defaults to searching the PATH
# set :cvs, "/path/to/cvs"       # defaults to searching the PATH
# set :gateway, "gate.host.com"  # default to no gateway

# =============================================================================
# SSH OPTIONS
# =============================================================================
# ssh_options[:keys] = %w(/path/to/my/key /path/to/another/key)
# ssh_options[:port] = 25
ssh_options[:port] = 6969

# =============================================================================
# TASKS
# =============================================================================
# Define tasks that run on all (or only some) of the machines. You can specify
# a role (or set of roles) that each task should be executed on. You can also
# narrow the set of servers to a subset of a role by specifying options, which
# must match the options given for the servers to select (like :primary => true)

# no sudo access on txd :)

desc "Checks out rails rev ##{rails_version}"
task :after_symlink do
  run <<-CMD
    cd #{current_release} &&
    rake init REVISION=#{rails_version} RAILS_PATH=/home/jarkko/projects/rails
  CMD
  run ""
end

after "deploy:symlink", "symlink_local_conf"

task :symlink_local_conf, :roles => :app, :except => {:no_release => true, :no_symlink => true} do
  run "ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml"
end

