name "install_app_server"
description "Install Application Server Role"
run_list(
  'recipe[install_packages]',
  'recipe[install_mysql_client]',
  'recipe[install_nginx]'
)