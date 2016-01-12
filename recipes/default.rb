# Runs proxysql
# If the image is not available, pulls it from the registry.
# If there is no image in the registry, build it first, then push it

config = data_bag_item(node['proxysql']['databag'],node.chef_environment)[node['proxysql']['databag_section']]
secrets = Chef::EncryptedDataBagItem.load(node['proxysql']['secret_databag'],node.chef_environment)[node['proxysql']['databag_section']]

config.deep_merge(secrets)

run_image = "#{node['docker']['registry']}/#{node['proxysql']['run_image']}:#{node['proxysql']['run_image_tag']}"
config_file = config['config_file'] || node['proxysql']['config_file']
config_dir = config_file.split("/")[0..-2].join("/")
frontend_port = node['proxysql']['frontend']['port']
admin_port = node['proxysql']['admin']['port']

#Try to pull from registry first
docker_image run_image do
  action :pull_if_missing
  ignore_failure true
end

#If the pull fails, let's build the image
docker_image run_image do
  action :build_if_missing
  action :push
  source "#{Chef::node[:file_cache_path]}/dockerfiles/proxysql"
  only_if "docker images -q #{run_image} | wc -l"
end


#Inotify and docker don't work together if you use volume to bind mount a single file
#Actually, since docker v1.1.0 editing a mounted file is almost impossible
#(http://docs.docker.com/userguide/dockervolumes/#mount-a-host-file-as-a-data-volume)
#Mount a directory instead, and put your files inside
directory config_dir do
  owner 'root'
  group 'root'
  mode 0644
  recursive true
end

template config_file do
  source node['proxysql']['config_template']
  owner 'root'
  group 'root'
  mode '0644'
  variables ({
    :config => config
  })
  notifies :speak, 'hipchat_msg[Config_Changed]', :immediately
end


hipchat_msg 'Config_Changed' do
  message "ProxySQL Config Changed on #{node['hostname']} (#{node.chef_environment} env)"
  color if node.chef_environment == 'ie1-prod' ? 'red':'yellow'
  notify if node.chef_environment == 'ie1-prod' ? true : false
  token node['hipchat']['token']
  room node['hipchat']['room']
  nickname node['hipchat']['name']
  action :nothing
end


docker_container 'proxysql' do
  container_name 'proxysql'
  image run_image
  init_type 'upstart'
  image run_image
  detach true
  port (["#{frontend_port}:#{frontend_port}","#{admin_port}:#{admin_port}"])
  volume "#{config_dir}:#{config_dir}"
  env (["CONF_FILE=#{config_file}", "DATA_DIR=#{node["proxysql"]["datadir"]}"])
end
