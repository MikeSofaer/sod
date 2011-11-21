config = YAML.load(File.read('/etc/sod/Sodfile'))["production"]
repo_name = config["repo"].split("/").last.gsub(".git","")
$APP_PATH = File.join(config["app_dir"],repo_name)

include_recipe("sod::bootstrap")

include_recipe (config["cookbook"] + "::default")

if config["test_suite_recipe"]
  include_recipe(config["cookbook"]+ "::" + config["test_suite_recipe"])
end

