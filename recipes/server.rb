# mcollective server config
# code dn365

remote_directory "/var/chef/gems" do
  source "gems"
  recursive true
end

gem_package "stomp_gem" do
  source "/var/chef/gems/stomp-1.2.4.gem"
  action :install
  options "--no-ri --no-rdoc"
end

gem_package "mcollective_gem" do
  source "/var/chef/gems/mcollective-2.1.0.gem"
  action :install
  options "--no-ri --no-rdoc"
end

directory "/etc/mcollective" do
  action :create
end

remote_directory "#{node["mcollective"]["libdir"]}" do
  source "plugins"
  recursive true
  notifies :restart, "service[mcollective]", :delayed
end

template "/etc/mcollective/server.cfg" do
  source "server.cfg.erb"
  mode 0600
  notifies :restart, "service[mcollective]", :delayed
end

service_path = value_for_platform(
  ["hpux"] => {"default" => "/sbin/init.d"},
  "default" => "/etc/init.d"
)

template "#{server_path}/mcollective" do
  source "mcollective.erb"
  mode 0755
end

service "mcollective" do
  case node[:platform]
  when "hpux"
     provider Chef::Provider::Service::Hpux
  when "aix"
     provider Chef::Provider::Service::Init
  end
    supports :restart => true, :status => true
    action [:enable, :start]
end