# create directory for fpm logs
directory "/var/log/engineyard/php-fpm" do
  owner node.engineyard.ssh_username
  group node.engineyard.ssh_username
  mode 0755
  action :create
end

# create error log for fpm
file "/var/log/engineyard/php-fpm/error.log" do
  owner node.engineyard.ssh_username
  group node.engineyard.ssh_username
  mode 0644
  action :create_if_missing
end

# create directory for unix socket(s)
directory "/var/run/engineyard" do
  owner node[:owner_name]
  group node[:owner_name]
  recursive true
  mode 0755
  action :create
end

# generate global fpm config
template "/etc/php-fpm.conf" do
  owner node[:owner_name]
  group node[:owner_name]
  mode 0644
  source "fpm-global.conf.erb"
  variables(:app_name => node[:php][:app_name])
end

# create releases directory for blog
directory "/data/#{node[:php][:app_name]}/releases" do
  owner node[:owner_name]
  group node[:owner_name]
  action :create
  recursive true    
  mode 0755
end

# create shared/config directory for blog
directory "/data/#{node[:php][:app_name]}/shared/config/" do
  owner node[:owner_name]
  group node[:owner_name]
  action :create
  recursive true    
  mode 0755
end

# create shared/log directory for blog
directory "/data/#{node[:php][:app_name]}/shared/log/" do
  owner node[:owner_name]
  group node[:owner_name]
  action :create
  recursive true    
  mode 0755
end

# chown blog directory to app user
execute "chown blog directory to user" do
  command "chown -R #{node[:owner_name]}:#{node[:owner_name]} /data/#{node[:php][:app_name]}"
end

# generate fpm pool config
template "/data/#{node[:php][:app_name]}/shared/config/fpm-pool.conf" do
  owner node.engineyard.ssh_username
  group node.engineyard.ssh_username
  mode 0644
  source "fpm-pool.conf.erb"
  variables({
    :app_name => node[:php][:app_name],
    :user => node.engineyard.ssh_username
  })
end
