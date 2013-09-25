## nginx ##

cookbook_file '/etc/pki/rpm-gpg/nginx_signing.key' do
  source 'nginx_signing.key'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

cookbook_file '/etc/yum.repos.d/nginx.repo' do
  source 'nginx.repo'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end


yum_package 'nginx' do
  action :install
  version node[:nginx][:version]
  flush_cache [:before]
end

file '/etc/nginx/conf.d/example_ssl.conf' do
  action :delete
end