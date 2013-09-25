gs_default = Chef::DataBagItem.load('global_settings', 'default')

default['commons']['deploy_user'] = gs_default['deploy_user']
default['commons']['deploy_home'] = gs_default['deploy_home']
default['commons']['application'] = gs_default['application']
default['commons']['deploy_to'] = gs_default['deploy_to']

default['commons']['rails_env'] = node['chef_environment']
default['commons']['ruby_version'] = gs_default['ruby_version']
default['commons']['rubygems_version'] = gs_default['rubygems_version']
default['commons']['rvm_gemset'] = gs_default['rvm_gemset']
default['commons']['rvm_path'] = gs_default['rvm_path']
default['commons']['rvm_ruby'] = "#{gs_default['rvm_path']}/bin/ruby-#{gs_default['ruby_version']}@#{gs_default['rvm_gemset']}"
default['commons']['rvm_rake'] = "#{gs_default['rvm_path']}/bin/rake-#{gs_default['ruby_version']}@#{gs_default['rvm_gemset']}"