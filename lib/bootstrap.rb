config = YAML.load(File.read('/etc/sod/Sodfile'))["production"]
repo_name = config["repo"].split("/").last.gsub(".git","")
$APP_PATH = File.join(config["app_dir"],repo_name)

execute "set environment script" do
  command "echo 'export PATH=/usr/local/rvm/rubies/#{config["ruby_version"]}/bin:/usr/local/rvm/gems/#{config["ruby_version"]}/bin:$PATH' > /etc/sod/environment"
end
execute "set environment in all shells" do
  command "echo 'source /etc/sod/environment' >> /etc/profile"
  not_if {`tail -n 1 /etc/profile` == "source /etc/sod/environment"}
end

include_recipe (config["cookbook"] + "::bootstrap")

execute "Install bundler" do
  command "gem install bundler --no-rdoc --no-ri"
end

execute "Install the bundle" do
  command "cd #{$APP_PATH} && bundle install --deployment"
end


