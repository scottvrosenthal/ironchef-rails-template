include_attribute 'commons'

gs_default = Chef::DataBagItem.load('global_settings', 'default')
env = Chef::DataBagItem.load('environments', node['chef_environment'])

default[:db][:rails_env] = node['chef_environment']
default[:db][:host] = env['db_host']
default[:db][:root_user] = env['db_root_user']
default[:db][:root_password] = env['db_root_password']
default[:db][:app_database] = env['db_app_database']
default[:db][:app_user] = env['db_app_user']
default[:db][:app_password] = env['db_app_password']

default[:env][:application_url] = env["application_url"]
default[:env][:application_base_url_redirect] = env["application_base_url_redirect"]
default[:env][:application_short_base_url_redirect] = env["application_short_base_url_redirect"]

## aws ##

default[:env][:s3_bucket_uploads] = env["s3_bucket_uploads"]
default[:env][:s3_bucket_static] = env["s3_bucket_static"]

default[:env][:s3_base_host] = gs_default["s3_base_host"]
default[:env][:s3_base_url] = gs_default["s3_base_url"]

default[:env][:aws_user] = gs_default["aws_user"]
default[:env][:aws_access_key_id] = gs_default["aws_access_key_id"]
default[:env][:aws_secret_access_key] = gs_default["aws_secret_access_key"]

## unicorn ##

default[:unicorn][:user] = node['commons']['deploy_user']
default[:unicorn][:worker_processes] = [node[:cpu][:total].to_i * 4, 8].min
default[:unicorn][:backlog] = 1024
default[:unicorn][:timeout] = 60
default[:unicorn][:preload_app] = true
default[:unicorn][:before_fork] = 'sleep 1'
default[:unicorn][:tcp_nodelay] = true
default[:unicorn][:tcp_nopush] = false
default[:unicorn][:tries] = 5
default[:unicorn][:delay] = 0.5
default[:unicorn][:accept_filter] = "httpready"

## nginx ##

default[:nginx][:worker_processes] = [node[:cpu][:total].to_i, 2].min
default[:nginx][:dir] = "/etc/nginx"
default[:nginx][:log_dir] = "/var/log/nginx"
default[:nginx][:server_names_hash_bucket_size] = "64"
default[:nginx][:types_hash_max_size] = "2048"
default[:nginx][:types_hash_bucket_size] = "64"

## nginx - app server settings ##

default[:nginx][:unicorn_fail_timeout] = "5"

default[:nginx][:keepalive_timeout] = "10"

default[:nginx][:client_max_body_size] = "10m"
default[:nginx][:client_body_buffer_size] = "128k"

default[:nginx][:proxy_connect_timeout] = "30"
default[:nginx][:proxy_send_timeout] = "15"
default[:nginx][:proxy_read_timeout] = "15"

default[:nginx][:proxy_buffer_size] = "128k"
default[:nginx][:proxy_buffers] = "4 128k"

default[:nginx][:proxy_busy_buffers_size] = "256k"
default[:nginx][:proxy_temp_file_write_size] = "256k"