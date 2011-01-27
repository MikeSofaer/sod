config = YAML.load(File.read('/etc/sod/Sodfile'))["production"]
repo_name = config["repo"].split("/").last.gsub(".git","")
$APP_PATH = File.join(config["app_dir"],repo_name)


package "git-core" do
  action :install
end

directory config["app_dir"] do
  owner config["user"]
  group config["user"]
  action :create
end

execute "blow away current repo" do
  command "rm -rf #{$APP_PATH} || true"
end

execute "clone repo" do
  command "cd #{config["app_dir"]} && git clone #{config["repo"]}"
  user config["user"]
end

execute "set up the cookbook path for the full run" do
  command %{echo 'cookbook_path ["/etc/sod/cookbooks", "#{$APP_PATH}/chef/cookbooks"]' > /etc/sod/solo.rb}
end
