deploy_to = node['commons']['deploy_to']
deploy_home = node['commons']['deploy_home']
application = node['commons']['application']
deploy_user = node['commons']['deploy_user']

directory "#{deploy_home}/sites" do
  group deploy_user
  owner deploy_user
  mode 0775
  action :create
  recursive true
end

directory "#{deploy_to}" do
  group deploy_user
  owner deploy_user
  mode 0775
  action :create
  recursive true
end

directory "#{deploy_to}/shared" do
  group deploy_user
  owner deploy_user
  mode 0775
  action :create
  recursive true
end

directory "#{deploy_to}/releases" do
  group deploy_user
  owner deploy_user
  mode 0775
  action :create
  recursive true
end

# create shared/ directory structure
['log','config','system','pids','scripts'].each do |dir_name|
  directory "#{deploy_to}/shared/#{dir_name}" do
    group deploy_user
    owner deploy_user
    mode 0775
    action :create
    recursive true
  end
end

## application settings ##
=begin
# if using figaro gem configure per environment
template "#{deploy_to}/shared/config/application.yml" do
  mode 0644
  owner deploy_user
  group deploy_user
  source "application.yml.erb"
  variables(:env => node[:env])
end
=end

## database settings ##

template "#{deploy_to}/shared/config/database.yml" do
  mode 0644
  owner deploy_user
  group deploy_user
  source "database.yml.erb"
  variables(:db => node[:db])
end

## nginx settings ##

=begin
# example for environment specific templates
if node['chef_environment'] == 'production'
  template "#{node['nginx']['dir']}/nginx.conf" do
    source "nginx.conf-production.erb"
    only_if { File.exists? "#{node['nginx']['dir']}/nginx.conf" }
  end  
else
  template "#{node['nginx']['dir']}/nginx.conf" do
    source "nginx.conf.erb"
    only_if { File.exists? "#{node['nginx']['dir']}/nginx.conf" }
  end
end
=end

template "#{node['nginx']['dir']}/nginx.conf" do
  source "nginx.conf.erb"
  only_if { File.exists? "#{node['nginx']['dir']}/nginx.conf" }
end

## unicorn settings ##

execute "stop unicorn" do
  command "#{deploy_to}/shared/scripts/unicorn stop"
  only_if do
    File.exists?("#{deploy_to}/shared/scripts/unicorn")
  end
end

template "#{deploy_to}/shared/config/unicorn.conf" do
  mode 0644
  owner deploy_user
  group deploy_user
  source "unicorn.conf.erb"
  variables(:deploy => node['commons'], :application => application)
end

template "#{deploy_to}/shared/scripts/unicorn" do
  mode 0770
  owner deploy_user
  group deploy_user
  source "unicorn.service.erb"
  variables(:deploy => node['commons'], :application => application)
end

service "unicorn_#{application}" do
  start_command "#{deploy_to}/shared/scripts/unicorn start"
  stop_command "#{deploy_to}/shared/scripts/unicorn stop"
  restart_command "#{deploy_to}/shared/scripts/unicorn restart"
  status_command "#{deploy_to}/shared/scripts/unicorn status"
  action :nothing
end

## ping nginx & unicorn status as deployer ##

bash "ping_app_services_status" do
  cwd deploy_home
  user deploy_user
  group deploy_user
  environment 'USER' => "#{deploy_user}", 'HOME' => "#{deploy_home}"
  code <<-EOH
    sudo service nginx status
    #{deploy_to}/shared/scripts/unicorn status
  EOH
end

bash "restart_nginx_services" do
  cwd deploy_home
  user deploy_user
  group deploy_user
  environment 'USER' => "#{deploy_user}", 'HOME' => "#{deploy_home}"
  code <<-EOH
    sudo service nginx restart
  EOH
end


