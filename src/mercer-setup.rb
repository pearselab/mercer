desc "Install R packages"
task :r_packages do `Rscript "src/packages.R"` end

desc "Setup mercer folders"
task :folders => ["group-work", "my-work", "my-work/to-do", "my-work/done"]
directory 'group-work'
directory 'my-work'
directory 'my-work/to-do'
directory 'my-work/done'

desc "Setup logging"
file "timestamp.yml" do File.open("my-work/timestamp.yml", "w") end

desc "Setup configuration file"
file "config.yml" do File.open("config.yml", "w") end
