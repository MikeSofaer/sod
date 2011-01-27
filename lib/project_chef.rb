config = YAML.load(File.read('/etc/sod/Sodfile'))["production"]
repo_name = config["repo"].split("/").last.gsub(".git","")
$APP_PATH = File.join(config["app_dir"],repo_name)

execute "prepend ruby executables to the path" do
  command "echo 'export PATH=/usr/local/rvm/rubies/#{config["ruby_version"]}/bin:/usr/local/rvm/gems/#{config["ruby_version"]}/bin:$PATH' >> /etc/profile"
  not_if {`cat /etc/profile`.split("\n").last.split(":").select{|s| s.match /rubies/}.first == "/usr/local/rvm/rubies/#{config["ruby_version"]}/bin"}
end

include_recipe (config["cookbook"] + "::bootstrap")

execute "Install bundler" do
  command "gem install bundler --no-rdoc --no-ri"
end

execute "Install the bundle" do
  command "cd #{$APP_PATH} && bundle install --deployment"
end

ruby_block "load the bundle" do
  block do
    ENV["BUNDLE_GEMFILE"]=File.join($APP_PATH, "Gemfile")
    Gem.clear_paths
    require 'bundler'
    Bundler.require
  end
end

include_recipe (config["cookbook"] + "::default")

if config["test_suite_recipe"]
  include_recipe(config["cookbook"]+ "::" + config["test_suite_recipe"])
end

