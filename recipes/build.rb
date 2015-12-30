# Builds proxysql and output the files in a directory defined in node attributes
# Please check the list of dependencies needed by proxysql to run
# https://github.com/renecannao/proxysql/tree/master/docker/images/proxysql/proxysql


build_image = "#{node["docker"]["registry"]}/#{node["proxysql"]["build_image"]}:#{node["proxysql"]["build_image_tag"]}"

git "#{Chef::Config[:file_cache_path]}/dockerfiles" do
  action :checkout
  repository node["proxysql"]["repo"]
  revision node["proxysql"]["branch"]
  ssh_wrapper "/etc/chef/wrap-ssh4git.sh"
  notifies :build, "docker_image[#{build_image}]", :immediately
end

docker_container "proxysql_build" do
  container_name "proxysql_build"
  image build_image
  init_type "upstart"
  detach false
  volume "#{node["proxysql"]["build_dir"]}:/export"
  remove_automatically true
  not_if { ::Dir.exists?(node["proxysql"]["build_dir"]) }
  notifies :remove , "docker_image[#{build_image}]", :delayed
  action :nothing
end

#The timeout is 1hr, it takes a lot of time to compile proxysql
docker_image build_image do
  cmd_timeout 3600
  source "#{Chef::Config[:file_cache_path]}/dockerfiles/proxysql/compile/"
  action :nothing
  notifies :start, "docker_container[proxysql_build]", :delayed
end
