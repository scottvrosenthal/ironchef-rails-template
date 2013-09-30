set :chef_environments, %w(staging production)

# don't forget to run locally
# chmod 600 /your-full/local-path-to-ssh-key/xxxxx_keypair_ec2.pem
# ssh-add /your-full/local-path-to-ssh-key/xxxxx_keypair_ec2.pem

ssh_options[:keys] = File.expand_path('~/ssh_keys/xxxxx_keypair_east_ec2.pem')
default_run_options[:pty] = true

set :user, 'ec2-user'
set :use_sudo, false
