# Unmask the PHP package (includes PHP-FPM)
enable_package "#{node[:php][:full_atom]}" do
  version "#{node[:php][:version]}"
end

# Install PHP
package "#{node[:php][:full_atom]}" do
  version "#{node[:php][:version]}"
  action :install
end

# Fix links with libmysqlclient.so
execute "Fix links between php and libmysqlclient.so" do
 command "revdep-rebuild"
 not_if { FileTest.exists?("/home/#{node[:owner_name]}/revdep_required") }
end

# Drop a file in place so we don't run revdep-rebuild every time
execute "Drop revdep_required into place" do
 command "touch /home/#{node[:owner_name]}/revdep_required"
end
