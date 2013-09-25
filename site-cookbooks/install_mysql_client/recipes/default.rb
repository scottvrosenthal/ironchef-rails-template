mysql_version = node['mysql']['version']
%w(client devel shared).each do |mysql_rpm|
  mysql_rpm_url = "http://dev.mysql.com/get/Downloads/MySQL-5.6/MySQL-#{mysql_rpm}-#{mysql_version}.el6.x86_64.rpm/from/http://cdn.mysql.com/"
  mysql_rpm_filename = "MySQL-#{mysql_rpm}-#{mysql_version}.el6.x86_64.rpm"
  mysql_rpm_package = mysql_rpm_filename.split(/-/,3)[0..1].join('-')
  
  remote_file "/tmp/#{mysql_rpm_filename}" do
    source mysql_rpm_url
    not_if { File.exists? "/tmp/#{mysql_rpm_filename}" }
  end

  package mysql_rpm_package do
    provider Chef::Provider::Package::Rpm
    source "/tmp/#{mysql_rpm_filename}"
    action :install
  end
end

execute 'yum clean dbcache'