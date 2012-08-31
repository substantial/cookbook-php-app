
# put the upstream configuration in place for php-fpm

template "/etc/nginx/servers/upstream.conf" do
  owner node[:owner_name]
  group node[:owner_name]
  mode 0644
  source "upstream.conf.erb"
  variables(:app_name => node[:php][:app_name])
end
