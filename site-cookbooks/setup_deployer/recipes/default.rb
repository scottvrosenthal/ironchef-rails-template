deploy_user = node['commons']['deploy_user']
deploy_home = node['commons']['deploy_home']

rails_env = node['commons']['rails_env']
ruby_version = node['commons']['ruby_version']
rubygems_version = node['commons']['rubygems_version']
rvm_gemset = node['commons']['rvm_gemset']
rvm_path = node['commons']['rvm_path']

group deploy_user do
  action :create
end

user deploy_user do
  supports manage_home: true
  comment "Deploy User"
  gid deploy_user
  home deploy_home
end

#   content "deployer ALL = NOPASSWD: ALL"
sudoer_path = "/etc/sudoers.d/#{deploy_user}"
bash "create sudoers for #{deploy_user}" do
  user "root"
  code <<-EOH
    touch #{sudoer_path}
    echo "#{deploy_user} ALL=(ALL) NOPASSWD: ALL" > #{sudoer_path}
    chmod 440 #{sudoer_path}
  EOH
  not_if { ::File.exists?(sudoer_path) }
end


directory "#{deploy_home}/.ssh" do
  owner deploy_user
  group deploy_user
  mode 0700
  action :create
end

cookbook_file "#{deploy_home}/.ssh/authorized_keys" do
  source "authorized_keys"
  owner deploy_user
  group deploy_user
  mode 0600
  action :create
end

cookbook_file "#{deploy_home}/.bash_profile" do
  source "bash_profile"
  owner deploy_user
  group deploy_user
  mode 0644
  action :create
end

template "#{deploy_home}/.bashrc" do
  source "bashrc.erb"
  owner deploy_user
  group deploy_user
  mode 0644
  action :create
end

cookbook_file "#{deploy_home}/.gemrc" do
  source "gemrc"
  owner deploy_user
  group deploy_user
  mode 0644
  action :create
end

bash "install_rvm" do
  cwd deploy_home
  user deploy_user
  group deploy_user
  environment 'USER' => "#{deploy_user}", 'HOME' => "#{deploy_home}"
  code <<-EOH
    curl -sL https://get.rvm.io | bash -s stable
  EOH
  not_if { ::File.exists?(rvm_path) }
end

bash "install_ruby-#{ruby_version}" do
  cwd deploy_home
  user deploy_user
  group deploy_user
  environment 'USER' => "#{deploy_user}", 'HOME' => "#{deploy_home}"
  code <<-EOH
    source #{rvm_path}/scripts/rvm
    rvm install ruby-#{ruby_version}
  EOH
  not_if { ::File.exists?("#{rvm_path}/rubies/ruby-#{ruby_version}") }
end

bash "install_rubygems-#{rubygems_version}" do
  cwd deploy_home
  user deploy_user
  group deploy_user
  environment 'USER' => "#{deploy_user}", 'HOME' => "#{deploy_home}"
  code <<-EOH
    source #{rvm_path}/scripts/rvm
    rvm rubygems #{rubygems_version}
  EOH
  not_if { "gem -v | grep '#{rubygems_version}'" }
end

bash "create_gemset-#{rvm_gemset}" do
  cwd deploy_home
  user deploy_user
  group deploy_user
  environment 'USER' => "#{deploy_user}", 'HOME' => "#{deploy_home}"
  code <<-EOH
    source #{rvm_path}/scripts/rvm
    rvm --ruby-version --create  #{ruby_version}@#{rvm_gemset}
    rvm use #{ruby_version}@#{rvm_gemset} --default
  EOH
  not_if { ::File.exists?("#{deploy_home}/.ruby-gemset") }
end
