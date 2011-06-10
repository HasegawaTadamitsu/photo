set :application, "upload"
set :repository,  "git@github.com:HasegawaTadamitsu/photo.git"
set :deploy_to,   "/usr/local/data/program/#{application}"
set :user,         "mainte"
set :use_sudo,    false

set :scm, :git

role :web, "uhpic"
role :app, "uhpic"
role :db,  "uhpic", :primary => true

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end

namespace :deploy do
   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end
 end
