################################
# Headers ######################
################################
# Dependencies and wrapper functions
require './src/mercer-util.rb'

# Sub-tasks (see below for groups with these names)
require './src/mercer-clean.rb'
require './src/mercer-setup.rb'

################################
# Global task definitions ######
################################
# Default task: help
task :default => :help
desc "Mercer command overview"
task :help do
  puts "Mercer - group (literature review software"
  puts "\t\t\t\t\thttps://github.com/pearselab/mercer"  
  puts "Useful commands:"
  puts "  rake setup                     - Install Mercer dependencies and setup user"
  puts "  rake sync                      - Sync data/code with group"
  puts "  rake clobber                   - Wipe everything and start afresh (!DANGER!)"
  puts "  rake search[term]              - Search WoS for *term*"
  puts "  rake assign[result,user,inst]  - Assign search *result* (to user, with instr.)"
  puts "  rake --tasks                   - Lists everything Mercer does"
end

# Install
desc "Install all software and setup tyrell folders"
task :setup => [:before_setup, :folders, "timestamp.yml", "config.yml", :r_packages, :user_authenticate]
task :before_install do
  puts "\t ... Setting up Mercer folders, files, and user"
end

# Clobber
CLOBBER.include("group-work/*")
CLOBBER.include("my-work/*")
CLOBBER.include("timestamp.yml")
CLOBBER.include("config.yml")
Rake::Task['clobber'].comment = "Delete all data, including large downloads"
