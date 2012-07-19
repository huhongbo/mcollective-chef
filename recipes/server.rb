# mcollective server config
# code dn365

remote_directory "/var/chef/gems" do
  source "gems"
  recursive true
end

gem_package "stomp" do
  source "/var/chef/gems/stomp-1.2.4.gem"
  options "--no-ri --no-rdoc"
  version "1.2.4"
  action :install
end

gem_package "mcollective" do
  source "/var/chef/gems/mcollective-2.1.0.gem"
  options "--no-ri --no-rdoc"
  version "2.1.0"
  action :install
end

directory "/etc/mcollective" do
  action :create
end
directory "/var/chef/lock" do
  action :create
end

remote_directory "#{node["mcollective"]["libdir"]}" do
  source "plugins"
  recursive true
  notifies :restart, "service[mcollective]", :delayed
end

template "/etc/mcollective/server.cfg" do
  source "server.cfg.erb"
  notifies :restart, "service[mcollective]", :delayed
end

service_path = value_for_platform(
  ["hpux"] => {"default" => "/sbin/init.d"},
  "default" => "/etc/init.d"
)

template "#{service_path}/mcollective" do
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
    action :start
end


  ruby_block "store node data locally" do
    block do
    
      state = ::File.open("/etc/mcollective/chefnode.txt", "w")
      node.run_state[:seen_recipes].keys.each do |recipe|
        state.puts("recipe.#{recipe}")
      end
      node.run_list.roles.each do |role|
        state.puts("role.#{role}")
      end
      node[:tags].each do |tag|
        state.puts("tag.#{tag}")
      end    
    
      state.close  
    end
  end
  
ruby_block "create facts file" do
  block do
    state = ::File.open("/etc/mcollective/facts.yaml", "w")
    state.puts("---\n")
    node['mcollective']['fact_whitelist'].each do |facts|
      keys = node["#{facts}"]
      state.puts("#{facts}: #{keys}")
    end
    
    state.close
  end
end

if File.exist?("/var/log/mcollective.log")
  file_time = File.mtime("/var/log/mcollective.log").strftime("%Y%m%d%H%M%S")
  time_now = Time.now.strftime("%Y%m%d%H%M%S") 
  time_value = (time_now.to_i - file_time.to_i) / 60
  unless time_value < 10
    service "mcollective" do
      case node[:platform]
      when "hpux"
         provider Chef::Provider::Service::Hpux
      when "aix"
         provider Chef::Provider::Service::Init
      end
        supports :restart => true, :status => true
        action :restart
    end
  end
end
  


