# install client
# code dn365

template "/etc/mcollective/client.cfg" do
  source "client.cgf.erb"
end

remote_directory "/var/chef/gems" do
  source "gems"
  recursive true
end

gem_package "mcollective-client" do
  source "/var/chef/gems/mcollective-client-2.1.1.gem"
  options "--no-ri --no-rdoc"
  version "2.1.1"
  action :install
end