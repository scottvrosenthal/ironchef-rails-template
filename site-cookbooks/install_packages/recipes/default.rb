execute 'yum-config-manager --quiet --enable epel' do
  not_if "yum-config-manager epel | grep 'enabled = True'"
end

execute 'yum update -y'

# packages to remove
%w(
landscape-common
landscape-client
).each do |pkg|
  package pkg do
    action :purge
  end
end

# packages to install
["ImageMagick",
 "ImageMagick-devel",
 "autoconf",
 "automake",
 "bison",
 "bzip2",
 "compat-libstdc++-33",
 "curl",
 "curl-devel",
 "elfutils-libelf-devel",
 "expect",
 "gcc",
 "gcc-c++",
 "git",
 "glibc-devel",
 "libaio-devel",
 "libffi-devel",
 "libstdc++-devel",
 "libtool",
 "libxml2",
 "libxml2-devel",
 "libxslt",
 "libxslt-devel",
 "libyaml-devel",
 "make",
 "mysql",
 "mysql-devel",
 "nginx",
 "nodejs",
 "ntp",
 "openssl",
 "openssl-devel",
 "patch",
 "pcre",
 "pcre-devel",
 "procps",
 "readline",
 "readline-devel",
 "screen",
 "sqlite-devel",
 "sysstat",
 "vim-enhanced",
 "wget",
 "zlib",
 "zlib-devel"].each do |pkg|
  package pkg do
    retries 2
    retry_delay 10
    action :install
  end
end


execute 'yum clean dbcache'
execute 'yum clean all'
execute 'yum makecache'
