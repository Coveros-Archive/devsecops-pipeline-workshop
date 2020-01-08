#
# Cookbook:: maven-settings
# Recipe:: default
#
# Copyright:: 2020, Coveros, Inc., All Rights Reserved.

nexus_url = search(
  :node,
  "policy_name:nexus-repo AND policy_group:#{node.policy_group}"
).map do |node|
  "http://#{node['ipaddress']}/repository/maven-public"
end

directory node['maven_settings']['settings_dir'] do
  owner 'root'
  group 'root'
  action :create
end

template "#{node['maven_settings']['settings_dir']}/settings.xml" do
  source 'settings.xml.erb'
  variables(
    'nexus_url': nexus_url[0]
  )
end
